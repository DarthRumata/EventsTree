//
//  MainViewController.swift
//  EventNodeExample
//
//  Created by Rumata on 6/21/17.
//  Copyright © 2017 DarthRumata. All rights reserved.
//

import UIKit
import Events

/// EventNode is used here only for TreeViews to make main functionality more clear
/// Of course it can be used for other tasks occurred in this app
class MainViewController: UIViewController {

  /// DEMO: Simplified access to node for easier app structure
  @IBOutlet fileprivate weak var rootNodeView: TreeNodeView!
  @IBOutlet private weak var leftBranchOne: TreeNodeView!
  @IBOutlet private weak var leftBranchTwo: TreeNodeView!
  @IBOutlet private weak var leftBranchThree: TreeNodeView!
  @IBOutlet private weak var rightBranchOne: TreeNodeView!

  @IBOutlet weak var bottomToolbarConstraint: NSLayoutConstraint!

  fileprivate var toolbarState: ToolbarState = .hidden

  // MARK: View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    /// Also just a demo version. In real app you should create
    /// subclass of EventNode as some Model/Logic class 
    /// in the same time as its Module created
    let rootEventNode = EventNode(parent: nil)
    rootNodeView.eventNode = rootEventNode
    rightBranchOne.eventNode = EventNode(parent: rootEventNode)
    let firstLeftEventNode = EventNode(parent: rootEventNode)
    leftBranchOne.eventNode = firstLeftEventNode
    let secondLeftEventNode = EventNode(parent: firstLeftEventNode)
    leftBranchTwo.eventNode = secondLeftEventNode
    leftBranchThree.eventNode = EventNode(parent: secondLeftEventNode)

    /// DEMO: much better have separate subclass of EventNode for this screen
    rootEventNode.addHandler { (event: TreeNodeView.Event) in
      if case .nodeSelected(let view) = event, view != nil {
        self.changeToolbarState(to: .shown)
      }
    }

    /// Added recognizer to delesect current node
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnScreen))
    view.addGestureRecognizer(recognizer)
  }

  // MARK: Actions

  @IBAction func didTapAddHandler(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let destinationId = String(describing: AddHandlerViewController.self)
    let controller = storyboard.instantiateViewController(withIdentifier: destinationId) as! AddHandlerViewController
    controller.saveHandler = { handlerInfo in
      print(handlerInfo)
    }
    present(controller, animated: true, completion: nil)
  }

  @IBAction func didTapRaiseEvent(_ sender: Any) {
    rootNodeView.eventNode.raise(event: Event.userSentEvent)
  }

}

extension MainViewController {

  enum Event: Events.Event {
    case userSentEvent
  }

}

private extension MainViewController {

  enum ToolbarState {
    case shown, hidden

    var bottomOffset: CGFloat {
      switch self {
      case .shown:
        return 0

      case .hidden:
        return -44
      }
    }
  }

  func changeToolbarState(to state: ToolbarState) {
    if toolbarState == state {
      return
    }

    toolbarState = state
    bottomToolbarConstraint.constant = toolbarState.bottomOffset

    UIView.animate(withDuration: 0.2) { 
      self.view.layoutIfNeeded()
    }
  }

  @objc func didTapOnScreen() {
    changeToolbarState(to: .hidden)
    /// DEMO: better to use event from that class where it is emitted
    rootNodeView.eventNode.raise(event: TreeNodeView.Event.nodeSelected(nil))
  }

}

