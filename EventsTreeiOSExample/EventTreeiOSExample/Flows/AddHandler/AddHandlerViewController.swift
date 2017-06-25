//
//  AddHandlerViewController.swift
//  EventNodeExample
//
//  Created by Rumata on 6/22/17.
//  Copyright © 2017 DarthRumata. All rights reserved.
//

import Foundation
import UIKit
import Events

struct HandlerInfo {
  let tipText: String
  let handlerMode: CaptureMode
}

class AddHandlerViewController: UIViewController {

  var saveHandler: ((HandlerInfo) -> Void)!

  @IBOutlet fileprivate weak var tipTextField: UITextField!
  /// DEMO: MWSegmentedControl is bad component - don't use it in prodaction
  @IBOutlet fileprivate weak var captureModePicker: MWSegmentedControl!
  @IBOutlet fileprivate weak var errorMessageLabel: UILabel!

  // MARK: View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    captureModePicker.allowMultipleSelection = true
    captureModePicker.buttonTitles = CaptureMode.list.map { $0.title }
    captureModePicker.font = UIFont(name: "Verdana", size: 12)
    captureModePicker.selectedIndexes = [0]
    tipTextField.delegate = self

    let recognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    view.addGestureRecognizer(recognizer)
  }

  // MARK: Actions

  @IBAction private func didTapCancel() {
    closeScreen()
  }

  @IBAction private func didTapSave() {
    if validateInput() {
      closeScreen()
      let info = HandlerInfo(tipText: tipTextField.text!, handlerMode: selectedCaptureMode)
      saveHandler(info)
    }
  }

}

extension AddHandlerViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    hideKeyboard()
    return true
  }

}

private extension CaptureMode {

  var title: String {
    switch self {
    case CaptureMode.onPropagate:
      return "On propagate"

    case CaptureMode.onRaise:
      return "On raise"

    case CaptureMode.consumeEvent:
      return "Consume event"

    default:
      fatalError("Unsupported mode")
    }
  }

  static var list: [CaptureMode] {
    return [.onPropagate, .onRaise, .consumeEvent]
  }

  static func mode(by title: String) -> CaptureMode {
    switch title {
    case "On propagate":
      return .onPropagate

    case "On raise":
      return .onRaise

    case "Consume event":
      return .consumeEvent

    default:
      fatalError("Invalid title")
    }
  }

}

private extension AddHandlerViewController {

  var selectedCaptureMode: CaptureMode {
    return captureModePicker.selectedSegments.reduce([]) { (result, title) -> CaptureMode in
      var result = result
      let mode = CaptureMode.mode(by: title)
      result.insert(mode)

      return result
    }
  }

  func closeScreen() {
    dismiss(animated: true, completion: nil)
  }

  @objc func hideKeyboard() {
    view.endEditing(true)
  }

  func validateInput() -> Bool {
    let errorMessage: String

    defer {
      self.errorMessageLabel.text = errorMessage
    }

    guard !tipTextField.text!.isEmpty else {
      errorMessage = "You should fill tip text field"
      return false
    }

    guard !selectedCaptureMode.isDisjoint(with: [.onPropagate, .onRaise]) else {
      errorMessage = "You should pick onPropagate or/and onRaise mode"
      return false
    }

    errorMessage = ""

    return true
  }

}
