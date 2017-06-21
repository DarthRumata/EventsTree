//
//  Event.swift
//  ArchitectureGuideTemplate
//
//  Created by Rumata on 11/4/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

public protocol Event {

  var type: String { get }

}

public extension Event {

  var type: String {
    return String(reflecting: type(of: self))
  }

}
