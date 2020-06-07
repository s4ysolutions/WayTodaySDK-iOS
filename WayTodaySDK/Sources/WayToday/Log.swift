//
//  Log.swift
//  Way.Today
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

protocol Log {
  func debug(_ msg: StaticString)
  func debug(_ msg: StaticString, _ args: CVarArg...)
  func error(_ msg: StaticString)
  func error(_ msg: StaticString, _ args: CVarArg...)
}
