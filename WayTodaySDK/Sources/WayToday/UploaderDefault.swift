//
//  UploaderDefault.swift
//  Way.Today
//
//  Created by Sergey Dolin on 08/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import Foundation
import Rasat
import CoreLocation

public class UploaderDefault: Uploader {
    static private var _shared: Uploader?
    public static func shared(log: Log, wayTodayState: WayTodayState) -> Uploader {
        if (_shared == nil) {
            _shared = UploaderDefault(log: log, wayTodayState: wayTodayState)
        }
        return _shared!
    }
    
    private var disposeBag: DisposeBag?
    private let log: Log
    private let channelState = Channel<UploaderState> ()
    public var observableState: Observable<UploaderState>{
        get{
            return channelState.observable
        }
    }
    
    private let wayTodayState: WayTodayState
    // private var locationService: LocationService?
    // private var wayTodayService: WayTodayService?
    
    init (log: Log, wayTodayState: WayTodayState) {
        self.log = log
        self.wayTodayState = wayTodayState
    }
    
    deinit {
        stopListen()
    }
    
    private var prevLat: CLLocationDegrees = 0
    private var prevLon: CLLocationDegrees = 0
    
    public func reset() {
        prevLat = 0
        prevLon = 0
    }
    
    public func startListen(locationService: LocationService, wayTodayService: WayTodayService) throws {
        disposeBag?.dispose()
        disposeBag = DisposeBag()
        log.debug("UpdateDefault: start listen")
        disposeBag!.add(
            locationService.observableLocation.subscribe(id: "uploader", handler: {location in
                if self.wayTodayState.on {
                    let coordinate = location.coordinate
                    if (self.wayTodayState.tid != "" && abs(coordinate.longitude) > 0.0001 && abs(coordinate.latitude) < 85 && abs(coordinate.longitude - self.prevLon)>0.0001 && abs(coordinate.latitude - self.prevLat) > 0.0001) {
                        self.log.debug("UpdateDefault: broadcast uploading")
                        self.prevLat = coordinate.latitude
                        self.prevLon = coordinate.longitude
                        self.channelState.broadcast(UploaderState.UPLOADING)
                        
                        do {
                            try wayTodayService.addLocation(
                                tid: self.wayTodayState.tid,
                                longitude: coordinate.longitude,
                                latitude: coordinate.latitude,
                                timestamp: UInt64(location.timestamp.timeIntervalSince1970),
                                complete: {ok in
                                    let status = ok ? UploaderState.IDLE : UploaderState.ERROR
                                    self.log.debug("UpdateDefault: broadcast \(status)")
                                    self.channelState.broadcast(status)
                            })
                        }catch{
                            self.log.debug("UpdateDefault: broadcast error")
                            self.channelState.broadcast(UploaderState.ERROR)
                        }
                    }else{
                        self.log.debug("UpdateDefault: upload skipped, no tid or locations too close")
                    }
                }
            })
        )
    }
    
    public func stopListen() {
        log.debug("UpdateDefault: stop listen")
        disposeBag?.dispose()
        disposeBag = nil
    }
}
