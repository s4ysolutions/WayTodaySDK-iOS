//
//  LogDefault.swift
//  Way.Today
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import os

class LogDefault: Log {
  private static let _shared = LogDefault()
//  private let logGeneral = OSLog(subsystem: "s4y.solutions.waytoday", category: "general")

  static var shared: Log {
    get {
      return _shared
    }
  }

  func debug(_ msg: StaticString) {
    os_log(msg, log: OSLog.default, type: .debug)
  }

  func debug(_ msg: StaticString, _ args: CVarArg...) {
    os_log(msg, log: OSLog.default, type: .debug, args)
  }


  func error(_ msg: StaticString) {
    os_log(msg, log: OSLog.default, type: .error)
  }

  func error(_ msg: StaticString, _ args: CVarArg...) {
    os_log(msg, log: OSLog.default, type: .error, args)
  }

}
