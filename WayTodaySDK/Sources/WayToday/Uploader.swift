//
//  Uploader.swift
//  Way.Today
//
//  Created by Sergey Dolin on 08/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import Rasat

public enum UploaderState {
  case IDLE
  case UPLOADING
  case ERROR
}

public protocol Uploader {
  var observableState: Observable<UploaderState> {get}
  func startListen(locationService: LocationService, wayTodayService: WayTodayService) throws
  func stopListen()
}
