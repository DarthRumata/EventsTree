//
//  TreeNodeView.swift
//  EventNodeExample
//
//  Created by Rumata on 6/22/17.
//  Copyright © 2017 DarthRumata. All rights reserved.
//

import Foundation
import UIKit
import Events
import AMPopTip

extension TreeNodeView {

  enum Event: Events.Event {
    case nodeSelected(TreeNodeView?)
    case bubbleUserEvent(SharedTime)
  }

  /// This is hack needed to avoid consuming all events in Event
  /// There is a big lack of current implementation - need to be fixed
  struct UserGeneratedEvent: Events.Event {}

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
      eventNode.addHandler { [weak self] (event: Event) in
        guard let strongSelf = self else {
          return
        }

        if case .nodeSelected(let view) = event {
          let newState: SelectedState = view == strongSelf ? .selected : .normal
          if strongSelf.selectedState == newState {
            return
          }

          strongSelf.selectedState = newState
        }
      }

      eventNode.addHandler { [weak self] (event: MainViewController.Event) in
        guard let strongSelf = self else {
          return
        }

        guard strongSelf.selectedState == .selected else {
          return
        }

        switch event {
        case .userSentEvent:
          strongSelf.eventNode.raise(event: Event.bubbleUserEvent(SharedTime()))
          strongSelf.eventNode.raise(event: UserGeneratedEvent())

        case .userAddedHandler(let handlerInfo):
          strongSelf.eventNode.addHandler(handlerInfo.handlerMode) { (event: UserGeneratedEvent) in
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
      }

      eventNode.addHandler(.onPropagate) { [weak self] (event: Event) in
        guard let strongSelf = self else {
          return
        }

        if case .bubbleUserEvent(let sharedTime) = event {
          /// TODO: Need to provide more convient implimentation via separate serial queue
          let scheduledTime = sharedTime.startTime
          sharedTime.startTime = sharedTime.startTime + 1
          DispatchQueue.main.asyncAfter(deadline: scheduledTime) {
            strongSelf.highlightedState = .onPropagate
            DispatchQueue.main.asyncAfter(deadline: scheduledTime + 1) {
              strongSelf.highlightedState = .none
            }
          }
        }
      }

      eventNode.addHandler(.onRaise) { [weak self] (event: Event) in
        guard let strongSelf = self else {
          return
        }

        if case .bubbleUserEvent(let sharedTime) = event {
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
  private let popTip = PopTip()

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
    let event = Event.nodeSelected(self)
    eventNode.raise(event: event)
  }

}

private extension TreeNodeView {

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

  func updateBackground() {
    backgroundColor = selectedState.color
  }
  
  func updateIcon() {
    eventDirectionMarker.image = highlightedState.icon
  }
  
}
