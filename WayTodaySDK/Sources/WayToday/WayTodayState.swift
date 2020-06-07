//
//  State.swift
//  Way.Today
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import Rasat

protocol WayTodayState {
  var on: Bool {get set}
  var observableOn: Observable<Bool> {get}
  var soundOn: Bool {get set}
  var tid: String {get set}
}
