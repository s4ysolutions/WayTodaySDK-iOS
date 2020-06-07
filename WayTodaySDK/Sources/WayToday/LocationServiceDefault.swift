//
//  LocationServiceDefault.swift
//  Way.Today
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//
import Rasat
import CoreLocation

class LocationServiceDefault: NSObject, LocationService{
    
    private static var _shared: LocationService?
    static func shared(log: Log, wayTodayState: WayTodayState) -> LocationService {
        if (_shared == nil) {
            _shared = LocationServiceDefault(log: log, wayTodayState: wayTodayState)
        }
        return _shared!
    }
    
    private class LocationDelegate: NSObject, CLLocationManagerDelegate {
        let channelLocation = Channel<CLLocation>()
        let log: Log
        let locationService: LocationService
        
        init(locationService: LocationService, log: Log) {
            self.locationService = locationService
            self.log = log
        }
        
        func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if (locations.count > 0) {
                log.debug("LocationServiceDefault: new location")
                channelLocation.broadcast(locations.last!)
            }
        }
        
        func locationManager(_ manager: CLLocationManager,
                             didChangeAuthorization status: CLAuthorizationStatus) {
            log.debug("LocationServiceDefault: authorization status changed")
            locationService.stop()
            locationService.start()
        }
    }
    
    private var locationManagerDelegate: LocationDelegate?
    var observableLocation: Observable<CLLocation> {
        get{
            return locationManagerDelegate!.channelLocation.observable
        }
    }
    
    private var subscriptionOn: Disposable?
    private let log: Log
    private let wayTodayState: WayTodayState
    private let manager = CLLocationManager()
    
    private var _status: LocationServiceStatus = .unknown
    var status: LocationServiceStatus {
        get {
            return _status
        }
    }
    
    let _channelStatus = Channel<LocationServiceStatus> ()
    var observableStatus: Observable<LocationServiceStatus> {
        get{
            return _channelStatus.observable
        }
    }
    
    init(log: Log, wayTodayState: WayTodayState) {
        self.log = log
        self.wayTodayState = wayTodayState
        super.init()
        locationManagerDelegate = LocationDelegate(locationService: self, log: log)
        
        if wayTodayState.on {
            start()
        } else {
            stop()
        }
        startObserveState()
    }
    
    deinit {
        stopObserveState()
    }
    
    internal func start() {
        manager.delegate = locationManagerDelegate
        
        if (_status == .started) {
            return
        }
        if (!CLLocationManager.locationServicesEnabled()){
            _status = .disabled
            _channelStatus.broadcast(.disabled)
            return
        }
        let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if authStatus != CLAuthorizationStatus.authorizedAlways {
            _status = .needAuthorization
            _channelStatus.broadcast(.needAuthorization)
            return
        }
        
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.pausesLocationUpdatesAutomatically = true
        // manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
        _status = .started
        _channelStatus.broadcast(.started)
        self.log.debug("Location Service started")
    }
    
    internal func stop() {
        manager.stopUpdatingLocation()
        _status = .stopped
        _channelStatus.broadcast(_status)
        log.debug("Location Service stopped")
    }
    
    private func startObserveState() {
        log.debug("LocationServiceDefault will subscribe to WayToday state")
        assert(subscriptionOn==nil)
        subscriptionOn = wayTodayState.observableOn.subscribe(id: "lsd", handler: {on in
            if on {
                self.start()
            } else {
                self.stop()
            }
        })
        self.log.debug("LocationServiceDefault subscribed to WayToday state")
    }
    
    private func stopObserveState() {
        subscriptionOn?.dispose()
        subscriptionOn = nil
        log.debug("LocationServiceDefault unsubscribed from WayToday state")
    }
}
