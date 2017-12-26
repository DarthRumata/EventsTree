//
//  Event.swift
//  EventNode
//
//  Created by Rumata on 11/4/16.
//  Copyright © 2016 DarthRumata. All rights reserved.
//

public protocol Event {

  var type: String { get }

}

public extension Event {

  var type: String {
    return String(reflecting: Swift.type(of: self))
  }

}
