//
//  LogDefault.swift
//  Way.Today
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import os

public class LogDefault: Log {
    private static let _shared = LogDefault()
    
    public static var shared: Log {
        get {
            return _shared
        }
    }
    
    public func debug(_ msg: String) {
        os_log("WayToday: %s", log: OSLog.default, type: .debug, msg)
    }
    
    public func debug(format: String, _ args: CVarArg...) {
        let m = String(format: format, args)
        os_log("WayToday: %s", log: OSLog.default, type: .debug, m)
    }
    
    public func error(_ msg: String) {
        os_log("WayToday: %s", log: OSLog.default, type: .error, msg)
    }
    
    public func error(format: String, _ args: CVarArg...) {
        let m = String(format: format, args)
        os_log("WayToday: %s", log: OSLog.default, type: .error, m)
    }
    
}
