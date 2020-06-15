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
    
    public func startListen(locationService: LocationService, wayTodayService: WayTodayService) throws {
        disposeBag?.dispose()
        disposeBag = DisposeBag()
        log.debug("UpdateDefault: start listen")
        disposeBag!.add(
            locationService.observableLocation.subscribe(id: "uploader", handler: {location in
                if self.wayTodayState.on {
                    if (self.wayTodayState.tid != "") {
                        self.log.debug("UpdateDefault: broadcast uploading")
                        self.channelState.broadcast(UploaderState.UPLOADING)
                        let coordinate = location.coordinate
                        do {
                            try wayTodayService.addLocation(
                                tid: self.wayTodayState.tid,
                                longitude: coordinate.longitude,
                                latitude: coordinate.latitude,
                                complete: {
                                    self.log.debug("UpdateDefault: broadcast idle")
                                    self.channelState.broadcast(UploaderState.IDLE)
                            })
                        }catch{
                            self.log.debug("UpdateDefault: broadcast error")
                            self.channelState.broadcast(UploaderState.ERROR)
                        }
                    }else{
                        self.log.debug("UpdateDefault: upload skipped, no tid")
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
