//
//  TreeNodeView.swift
//  EventNodeExample
//
//  Created by Rumata on 6/22/17.
//  Copyright © 2017 DarthRumata. All rights reserved.
//

import Foundation
import UIKit
import EventsTree
import AMPopTip

extension TreeNodeView {

  enum Events {
    struct NodeSelected: Event { let view: TreeNodeView? }
    struct EventImitationStarted: Event { let sharedTime: SharedTime }
    struct UserGeneratedEventRaised: Event {}
  }

  class SharedTime {
    var startTime: DispatchTime = .now()
  }

}

@IBDesignable
class TreeNodeView: UIView {

  @IBInspectable
  var title: String = "" {
    didSet {
      self.titleLabel.text = title
    }
  }

  var eventNode: EventNode! {
    didSet {
      addInitialHandlers()
    }
  }

  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var eventDirectionMarker: UIImageView!

  fileprivate var selectedState: SelectedState = .normal {
    didSet {
      updateBackground()
    }
  }

  fileprivate var highlightedState: HighlightedState = .none {
    didSet {
      updateIcon()
    }
  }
  fileprivate let popTip = PopTip()

  // MARK: Init

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    let nib = UINib(nibName: String(describing: TreeNodeView.self), bundle: nil)
    let content = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    addSubview(content)
    content.frame = bounds
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    layer.cornerRadius = 5
    layer.masksToBounds = true
  }

  // MARK: Actions

  @IBAction func didTapOnView() {
    let event = Events.NodeSelected(view: self)
    eventNode.raise(event: event)
  }

}

fileprivate extension TreeNodeView {

  /// TODO: Can be optimized by merging to states in OptionSet
  enum SelectedState {
    case normal, selected

    var color: UIColor {
      switch self {
      case .normal:
        return .lightGray

      case .selected:
        return .green

      }
    }
  }

  enum HighlightedState {
    case onPropagate, onRaise, none

    var icon: UIImage? {
      switch self {
      case .onPropagate: return UIImage(named: "arrowDown")
      case .onRaise: return UIImage(named: "arrowUp")
      case .none: return nil
      }
    }
  }

  func addInitialHandlers() {
    eventNode.addHandler { [weak self] (event: Events.NodeSelected) in
      guard let strongSelf = self else { return }

      let newState: SelectedState = event.view == strongSelf ? .selected : .normal

      if strongSelf.selectedState != newState {
        strongSelf.selectedState = newState
      }
    }

    eventNode.addHandler { [weak self] (event: MainViewController.Events.AddHandler) in
      guard let strongSelf = self else { return }
      guard strongSelf.selectedState == .selected else { return }

      let handlerInfo = event.info
      strongSelf.eventNode.addHandler(handlerInfo.handlerMode) { (event: Events.UserGeneratedEventRaised) in
        strongSelf.popTip.show(
          text: handlerInfo.tipText,
          direction: .down,
          maxWidth: 150,
          in: strongSelf.superview!,
          from: strongSelf.frame,
          duration: 2
        )
      }
    }

    eventNode.addHandler { [weak self] (event: MainViewController.Events.SendTestEvent) in
      guard let strongSelf = self else { return }
      guard strongSelf.selectedState == .selected else { return }

      let flowImitationEvent = Events.EventImitationStarted(sharedTime: SharedTime())
      strongSelf.eventNode.raise(event: flowImitationEvent)
      let userEvent = Events.UserGeneratedEventRaised()
      strongSelf.eventNode.raise(event: userEvent)
    }

    eventNode.addHandler { [weak self] (event: MainViewController.Events.RemoveHandler) in
      guard let strongSelf = self else { return }
      guard strongSelf.selectedState == .selected else { return }

      strongSelf.eventNode.removeHandlers(for: Events.UserGeneratedEventRaised.self)
    }

    eventNode.addHandler(.onPropagate) { [weak self] (event: Events.EventImitationStarted) in
      guard let strongSelf = self else {
        return
      }

      /// TODO: Need to provide more convient implimentation via separate serial queue
      let sharedTime = event.sharedTime
      let scheduledTime = sharedTime.startTime
      sharedTime.startTime = sharedTime.startTime + 1
      DispatchQueue.main.asyncAfter(deadline: scheduledTime) {
        strongSelf.highlightedState = .onPropagate
        DispatchQueue.main.asyncAfter(deadline: scheduledTime + 1) {
          strongSelf.highlightedState = .none
        }
      }
    }

    eventNode.addHandler(.onRaise) { [weak self] (event: Events.EventImitationStarted) in
      guard let strongSelf = self else {
        return
      }

      let sharedTime = event.sharedTime
      let scheduledTime = sharedTime.startTime
      sharedTime.startTime = sharedTime.startTime + 1
      DispatchQueue.main.asyncAfter(deadline: scheduledTime) {
        strongSelf.highlightedState = .onRaise
        DispatchQueue.main.asyncAfter(deadline: scheduledTime + 1) {
          if strongSelf.highlightedState == .onRaise {
            strongSelf.highlightedState = .none
          }
        }
      }
    }
  }

  func updateBackground() {
    backgroundColor = selectedState.color
  }
  
  func updateIcon() {
    eventDirectionMarker.image = highlightedState.icon
  }
  
}
