//
//  WayTodayServiceDefault.swift
//  Way.Today
//
//  Created by Sergey Dolin on 08/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import CoreLocation
import Foundation

public class WayTodayServiceDefault: WayTodayService {
    
    private static var _shared: WayTodayService?
    private let appname: String
    private let secret: String
    private let provider: String

    
    public static func shared(log: Log, wayTodayState: WayTodayState, appname: String, secret: String, provider: String) -> WayTodayService{
        if (_shared == nil) {
            _shared = WayTodayServiceDefault(
                address: "tracker.way.today:9101",
                log: log,
                wayTodayState: wayTodayState,
                appname: appname, secret: secret, provider: provider
            )
        }
        return _shared!
    }
    
    private let client: Grpc_TrackerServiceClient
    private let log: Log
    private let wayTodayState: WayTodayState
    
    init(address: String, log: Log, wayTodayState: WayTodayState, appname: String, secret: String, provider: String){
        self.appname = appname
        self.secret = secret
        self.provider = provider
        
        self.log = log
        self.wayTodayState = wayTodayState
        client = Grpc_TrackerServiceClient(address: address, secure: true)
    }
    
    public func ping(payload: String) throws {
        var request = Grpc_PingRequest()
        request.payload = payload
        try client.ping(request, completion: {(response, result) in
            // print(response?.payload)
        })
    }
    
    public func generateTid(prevTid: String, complete: @escaping (_ tid: String) -> Void) throws{
        //    log.debug("WayTodayService issue generateTid, prevID=\"%s\"", _prevTid)
        log.debug("WayTodayService issue generateTid")
        var request = Grpc_GenerateTrackerIDRequest()
        request.prevTid = prevTid
        try client.generateTrackerID(request, metadata: WSSE.grpcMetadata(appname: appname, secret: secret), completion: {(response, result) in
            let tid = response?.tid ?? ""
            complete(tid)
            self.log.debug("WayTodayService return generateTid")
            /*
             self.log.debug(
             "WayTodayService return generateTid, prevID=\"%s\", tid=\"%s\"",
             prevTid as NSString,
             tid as NSString
             )
             */
        })
    }
    
    public func addLocation(tid: String, longitude: CLLocationDegrees, latitude: CLLocationDegrees, timestamp: UInt64, complete: @escaping ()->Void) throws {
        var location = Models_Location()
        location.lat = Int64(lround(latitude * 10000000))
        location.lon = Int64(lround(longitude * 10000000))
        location.provider = provider
        location.sid = UUID.init().uuidString
        location.ts = timestamp
        var request = Grpc_AddLocationsRequest()
        request.tid = wayTodayState.tid
        request.locations = [location]
        try client.addLocations(request, metadata: WSSE.grpcMetadata(appname: appname, secret: secret), completion: {(response, result) in
            complete()
        })
    }
}
