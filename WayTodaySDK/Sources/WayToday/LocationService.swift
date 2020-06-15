//
//  LocationService.swift
//  Way.Today
//
//  Created by Sergey Dolin on 06/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import CoreLocation
import Rasat

public enum LocationServiceStatus : Int32 {
  case unknown
  case disabled
  case stopped
  case started
  case problem
}

public enum LocationServiceAuthorizationStatus : Int32 {
  case unknown
  case needAuthorization
  case Authorized
}

public protocol LocationService {
  var authorizationStatus: LocationServiceAuthorizationStatus {get}
  var status: LocationServiceStatus {get}
  var observableAuthorizationStatus: Observable<LocationServiceAuthorizationStatus> {get}
  var observableStatus: Observable<LocationServiceStatus> {get}
  var observableLocation: Observable<CLLocation> {get}
  var lastLocation: CLLocation? {get}
  func start()
  func stop()
  func requestAuthorization()
}
