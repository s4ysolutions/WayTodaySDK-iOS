//
//  State.swift
//  Way.Today
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import Rasat
import UIKit

class WayTodayStateDefault: WayTodayState {
  static let _shared = WayTodayStateDefault()
  static var shared: WayTodayState {
    get { return _shared}
  }

  private let _subjectOn = Subject<Bool>(UserDefaults.standard.bool(forKey: "on"))
  var observableOn: Observable<Bool> {
    get {
      print("get state observable")
      return _subjectOn.observable
    }
  }

  var on: Bool {
    get {
      return _subjectOn.value
    }
    set(on) {
      UserDefaults.standard.set(on, forKey: "on")
      _subjectOn.value=on
    }
  }

  var soundOn: Bool {
    get {
      return UserDefaults.standard.bool(forKey: "sndon")
    }
    set(on) {
      UserDefaults.standard.set(on, forKey: "sndon")
    }
  }

  var first = true
  var _tid: String = ""
  var tid: String {
    get {
      if (_tid == "") {
        _tid = UserDefaults.standard.string(forKey: "tid") ?? ""
      }
      return _tid
    }

    set(tid) {
      _tid = tid
      UserDefaults.standard.set(tid, forKey: "tid")
    }
  }


}
