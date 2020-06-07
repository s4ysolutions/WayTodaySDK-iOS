//
//  LocationService.swift
//  Way.Today
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import CoreLocation
import Rasat

enum LocationServiceStatus : Int32 {
  case unknown
  case disabled
  case needAuthorization
  case stopped
  case started
  case problem
}

protocol LocationService {
  var status: LocationServiceStatus {get}
  var observableStatus: Observable<LocationServiceStatus> {get}
  var observableLocation: Observable<CLLocation> {get}
  func start()
  func stop()
}
