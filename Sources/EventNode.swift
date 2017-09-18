//
//  EventNode.swift
//  EventNode
//
//  Created by Rumata on 12/12/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

public protocol EventDrivenInterface {

  func raise<T: Event>(event: T)
  func addHandler<T: Event>(_ captureMode: CaptureMode, _ handler: @escaping (T) -> Void)
  func removeHandlers<T: Event>(for eventType: T.Type, with captureMode: CaptureMode)
  func removeHandlers<T: Event>(for eventType: T.Type)
  func removeAllHandlers()

}

public struct CaptureMode : OptionSet {
  public let rawValue: Int

  public static let onRaise  = CaptureMode(rawValue: 1 << 0)
  public static let onPropagate = CaptureMode(rawValue: 1 << 1)
  public static let consumeEvent  = CaptureMode(rawValue: 1 << 2)

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

// This hack is needed to hide generic nature of handler to use it in non-generic context
protocol EventHandler {}

private struct EventHandlerContainer<E: Event>: EventHandler {

  private let handler: (E) -> Void
  private let handlerCaptureMode: CaptureMode

  init(handler: @escaping (E) -> Void, captureMode: CaptureMode) {
    self.handler = handler
    handlerCaptureMode = captureMode
  }

  func canHandle(with mode: CaptureMode) -> Bool {
    var mode = mode
    mode.subtract(.consumeEvent)
    return !mode.intersection(handlerCaptureMode).isEmpty
  }

  func handle(event: E, metadata: EventMetadata) {
    handler(event)
    if handlerCaptureMode.contains(.consumeEvent) {
      metadata.isHandled = true
    }
  }

}

open class EventNode: EventDrivenInterface {

  fileprivate var parent: EventNode?
  fileprivate lazy var children = NSHashTable<EventNode>.weakObjects()
  fileprivate var eventHandlers = [EventHandler]()
  
  fileprivate let identifier = ProcessInfo.processInfo.globallyUniqueString

  private init() {}

  public init(parent: EventNode?) {
    parent?.addChild(self)
  }

  func propagate<T: Event>(event: T, with metadata: EventMetadata) {
    captureEvent(event, mode: .onPropagate, metadata: metadata)

    children.allObjects.forEach {
      $0.propagate(event: event, with: metadata)
    }
  }

  func raise<T: Event>(event: T, with metadata: EventMetadata) {
    captureEvent(event, mode: .onRaise, metadata: metadata)

    guard let parent = parent else {
      propagate(event: event, with: metadata)
      
      return
    }

    parent.raise(event: event, with: metadata)
  }

  public func raise<T: Event>(event: T) {
    raise(event: event, with: EventMetadata())
  }
  
  public func addHandler<T: Event>(_ captureMode: CaptureMode = .onPropagate, _ handler: @escaping (T) -> ()) {
    precondition(!captureMode.isDisjoint(with: [.onPropagate, .onRaise]), "You should add onPropagate or/and onRaise mode")
    let container = EventHandlerContainer(handler: handler, captureMode: captureMode)
    eventHandlers.append(container)
  }

  public func removeHandlers<T>(for eventType: T.Type) where T : Event {
    eventHandlers = eventHandlers.filter { !($0 is EventHandlerContainer<T>) }
  }

  public func removeHandlers<T>(for eventType: T.Type, with captureMode: CaptureMode) where T : Event {
    eventHandlers = eventHandlers.filter { eventHandler in
      if let handlerContainer = eventHandler as? EventHandlerContainer<T>, handlerContainer.canHandle(with: captureMode) {
        return false
      }

      return true
    }
  }

  public func removeAllHandlers() {
    eventHandlers.removeAll()
  }
  
}

private extension EventNode {

  func addChild(_ child: EventNode) {
    child.parent = self
    children.add(child)
  }

  func removeChild(_ child: EventNode) {
    children.remove(child)
  }

  func captureEvent<E: Event>(_ event: E, mode: CaptureMode, metadata: EventMetadata) {
    for eventHandler in eventHandlers {
      if
        !metadata.isHandled,
        let container = eventHandler as? EventHandlerContainer<E>,
        container.canHandle(with: mode)
      {
        container.handle(event: event, metadata: metadata)
      }
    }
  }

}

extension EventNode: Equatable {}

public func == (lhs: EventNode, rhs: EventNode) -> Bool {
  return lhs.identifier == rhs.identifier
}
