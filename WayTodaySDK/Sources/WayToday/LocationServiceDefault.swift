//
//  LocationServiceDefault.swift
//  Way.Today
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//
import Rasat
import CoreLocation

func CLAuthorizationStatus2LocationServiceAuthorizationStatus(_ status: CLAuthorizationStatus) -> LocationServiceAuthorizationStatus {
    switch status {
    case .authorizedAlways:
        return .Authorized
    case .notDetermined:
        return .unknown
    case .restricted:
        return .needAuthorization
    case .denied:
        return .needAuthorization
    case .authorizedWhenInUse:
        return .needAuthorization
    @unknown default:
        return .needAuthorization
    }
}

public class LocationServiceDefault: NSObject, LocationService{
    
    private static var _shared: LocationService?
    public static func shared(log: Log, wayTodayState: WayTodayState) -> LocationService {
        if (_shared == nil) {
            log.debug("LocationServiceDefault getting shared")
            _shared = LocationServiceDefault(log: log, wayTodayState: wayTodayState)
        }
        return _shared!
    }
    
    private class LocationDelegate: NSObject, CLLocationManagerDelegate {
        let channelLocation = Channel<CLLocation>()
        let channelAuthorization = Channel<LocationServiceAuthorizationStatus>()
        let log: Log
        let locationService: LocationService
        var lastLocation: CLLocation? = nil
        
        init(locationService: LocationService, log: Log) {
            self.locationService = locationService
            self.log = log
        }
        
        func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if (locations.count > 0) {
                log.debug("LocationDelegate got new location")
                lastLocation = locations.last!
                channelLocation.broadcast(lastLocation!)
            }
        }
        
        func locationManager(_ manager: CLLocationManager,
                             didChangeAuthorization status: CLAuthorizationStatus) {
            log.debug("LocationDelegate authorization status changed \(status.rawValue)")
            channelAuthorization.broadcast(CLAuthorizationStatus2LocationServiceAuthorizationStatus(status))
        }
    }
    
    private var locationManagerDelegate: LocationDelegate!
    
    public var observableLocation: Observable<CLLocation> {
        get{
            return locationManagerDelegate.channelLocation.observable
        }
    }
    
    private var disposeBag: DisposeBag?
    private let log: Log
    private let wayTodayState: WayTodayState
    private let manager = CLLocationManager()
  
    private var _status: LocationServiceStatus = .unknown
    public var status: LocationServiceStatus {
        get {
            return _status
        }
    }
    
    public var authorizationStatus: LocationServiceAuthorizationStatus {
        get {
            let ast = CLAuthorizationStatus2LocationServiceAuthorizationStatus(CLLocationManager.authorizationStatus())
            log.debug(format: "LocationServiceDefault authorization status is \(ast)")
            return ast
        }
    }
    
    let _channelStatus = Channel<LocationServiceStatus> ()
    public var observableStatus: Observable<LocationServiceStatus> {
        get{
            return _channelStatus.observable
        }
    }
    
    public var lastLocation: CLLocation? {
        get {
            return locationManagerDelegate.lastLocation
        }
    }
    
    init(log: Log, wayTodayState: WayTodayState) {
        self.log = log
        self.wayTodayState = wayTodayState
        super.init()
        locationManagerDelegate = LocationDelegate(locationService: self, log: log)
        self.log.debug("LocationServiceDefault init with on=\(wayTodayState.on)")
        startObserveState()
    }
    
    deinit {
        stopObserveState()
    }
    
    public func start() {
        manager.delegate = locationManagerDelegate
        
        if (_status == .started) {
            self.log.debug("LocationServiceDefault already started")
            return
        }
        
        self.log.debug("LocationServiceDefault starting")
        if (!CLLocationManager.locationServicesEnabled()){
            self.log.debug("LocationServiceDefault start aborted because CLLocationManager")
            _status = .disabled
            _channelStatus.broadcast(.disabled)
            return
        }
        
        let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if authStatus != CLAuthorizationStatus.authorizedAlways {
            self.log.debug("LocationServiceDefault start requests authorization during start")
            _status = .needAuthorization
            _channelStatus.broadcast(.needAuthorization)
            return
        }
        
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 5
        manager.pausesLocationUpdatesAutomatically = false
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation //kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
        _status = .started
        _channelStatus.broadcast(.started)
        self.log.debug("LocationServiceDefault started")
    }
    
    public func stop() {
        manager.stopUpdatingLocation()
        _status = .stopped
        _channelStatus.broadcast(_status)
        log.debug("LocationServiceDefault stopped")
    }
    
    private func startObserveState() {
        assert(disposeBag==nil)
        disposeBag = DisposeBag()
        log.debug("LocationServiceDefault will subscribe to WayToday state")
        disposeBag!.add(wayTodayState.observableOn.subscribe(id: "lsd", handler: {on in
            if on {
                self.start()
            } else {
                self.stop()
            }
        }))
        self.log.debug("LocationServiceDefault subscribed to WayToday state")
        log.debug("LocationServiceDefault will subscribe to locationManagerDelegate authorization requests")
        disposeBag!.add(locationManagerDelegate.channelAuthorization.observable.subscribe(id: "lmd", handler: {status in
            if status != .Authorized {
                self.log.debug("LocationServiceDefault start requests authorization on change authorization status")
                self._status = .needAuthorization
                self._channelStatus.broadcast(self._status)
            } else if (self._status == .needAuthorization) {
                // in order to update status and UI
                if self.wayTodayState.on {
                    self.log.debug("LocationServiceDefault will start on authorization enabled")
                    self.start()
                } else {
                    self.log.debug("LocationServiceDefault will stop although authorization enabled")
                    self.stop()
                }
            }
        }))
        self.log.debug("LocationServiceDefault subscribed to locationManagerDelegate authorization requests")
    }
    
    private func stopObserveState() {
        disposeBag?.dispose()
        disposeBag = nil
        log.debug("LocationServiceDefault unsubscribed from WayToday state and locationManagerDelegate authorization requests"  )
    }
    
    public func requestAuthorization() {
        manager.requestAlwaysAuthorization()
    }
}
