//
//  Uploader.swift
//  Way.Today
//
//  Created by Sergey Dolin on 08/07/2019.
//  Copyright © 2019 S4Y Solutions. All rights reserved.
//

import Rasat

enum UploaderState {
  case IDLE
  case UPLOADING
  case ERROR
}

protocol Uploader {
  var observableState: Observable<UploaderState> {get}
  func startListen(locationService: LocationService, wayTodayService: WayTodayService) throws
  func stopListen()
}
