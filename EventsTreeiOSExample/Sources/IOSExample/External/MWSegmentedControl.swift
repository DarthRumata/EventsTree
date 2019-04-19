//
//  MWSegmentedControl.swift
//  90 Day
//
//  Created by Micah Wilson on 8/19/15.
//  Copyright (c) 2015 Micah Wilson. All rights reserved.
//

import UIKit

@objc protocol MWSegmentedControlDelegate {
  ///Set when segment changes
  @objc optional func segmentDidChange(control: MWSegmentedControl, value: Int)
}

class MWSegmentedControl: UIView {
  var buttonTitles = ["7", "21", "30", "60", "90"]
  var borderColor = UIColor(red:0.06, green:0.51, blue:1, alpha:1)
  var textColor = UIColor.darkGray
  var font = UIFont(name: "Avenir-Heavy", size: 36)
  var delegate: MWSegmentedControlDelegate?
  var selectedSegments = [String]()
  var selectedIndexes = [2]
  var allowMultipleSelection = false
  var value: Int!

  override func layoutSubviews() {
    self.layer.cornerRadius = 10
    self.layer.borderWidth = 2
    self.layer.borderColor = self.borderColor.cgColor
    self.layer.masksToBounds = true

    if self.subviews.count <= 0 {
      for (index, button) in buttonTitles.enumerated() {
        let buttonWidth = self.frame.width / CGFloat(buttonTitles.count)
        let buttonHeight = self.frame.height

        let newButton = UIButton(frame: CGRect(
          x: CGFloat(index) * buttonWidth,
          y: 0,
          width: buttonWidth,
          height: buttonHeight
        ))
        newButton.setTitle(button, for: .normal)
        newButton.setTitleColor(self.textColor, for: .normal)
        newButton.titleLabel?.font = self.font!
        newButton.addTarget(self, action: #selector(changeSegment), for: .touchUpInside)
        newButton.layer.borderWidth = 1
        newButton.layer.borderColor = self.borderColor.cgColor
        newButton.tag = index
        newButton.showsTouchWhenHighlighted = true
        self.addSubview(newButton)

        for selected in selectedIndexes {
          if selected == index {
            self.changeSegment(sender: newButton)
          }
        }
      }
    }
  }

  @objc func changeSegment(sender: UIButton) {
    if allowMultipleSelection {
      if sender.backgroundColor == borderColor {
        sender.backgroundColor = UIColor.clear
        sender.setTitleColor(textColor, for: .normal)

        for (index, segment) in self.selectedSegments.enumerated() {
          if segment == sender.titleLabel!.text! {
            self.selectedSegments.remove(at: index)
            break
          }
        }

      } else {
        sender.backgroundColor = borderColor
        sender.setTitleColor(UIColor.white, for: .normal)
        self.value = NSString(string: sender.titleLabel!.text!).integerValue
        self.selectedSegments.append(self.buttonTitles[sender.tag])
        self.delegate?.segmentDidChange!(control: self, value: self.value)
      }
    } else {
      for subview in self.subviews {
        if subview is UIButton {
          (subview as! UIButton).setTitleColor(self.textColor, for: .normal)
          (subview as! UIButton).backgroundColor = UIColor.clear
        }
      }
      sender.backgroundColor = borderColor
      sender.setTitleColor(UIColor.white, for: .normal)
      self.value = NSString(string: sender.titleLabel!.text!).integerValue
      self.delegate?.segmentDidChange!(control: self, value: self.value)
    }

  }
}
