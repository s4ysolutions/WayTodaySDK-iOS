//
//  Log.swift
//  Way.Today
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

public protocol Log {
  func debug(_ msg: String)
  func debug(format: String, _ args: CVarArg...)
  func error(_ msg: String)
  func error(format: String, _ args: CVarArg...)
}
