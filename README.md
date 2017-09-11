![pod version](https://img.shields.io/cocoapods/v/EventsTree.svg) 
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/DarthRumata/EventsTree)
![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-green.svg)  
  
__Made in Yalantis__. Inspired by https://github.com/mmrmmlrr/ModelsTreeKit

# Motivation

Imagine that you have iOS application with many screens. Each screen is managed by UIViewController and some data/logic/helper classes. All classes which linked to one screen I call Module. 

We don't discuss communication between classes inside a Module - it can be done pretty easy with delegate/callback/reactive signals.
But what if you need to communicate between different Modules? They can be placed far away from each other in navigation flow.
You can deal with it using NSNotificationCenter, or you can pull callbacks/delegates and etc across the whole application making it overcomplicated.

# Solution

Navigation flow of Modules in app is tree-like structure. And EventNode proposes tree-like solution for every such situation(not only Modules but every tree). 
Instead of creating route for every change we will provide **the single easy way** to delivering events where they are needed.

## Principles

1. All changes that emitted are equal and I call them - **Event**.
2. Every part of route(I call them **EventNode**) is the same as others, independant and shouldn't be aware of existance of other nodes or their relative position in tree.
3. Nodes are organized in tree: root node doesn't have parent, leaf nodes doesn't have children, other nodes have both.
Every node can have only one parent and unlimited number of children.
4. You can send event from every node - I call this **"Raise Event"**.
5. Every raised event will be delivered to **all** nodes. I call this - **"Event propagating"**.
6. Raised event is going to the root through the tree - **raising** and then going recursively to all children of root - **propagating**.
7. You can add unlimited number of **"Event Handlers"** to every node. Event handler can perform some closure for Event on raising or/and on progating stage.
8. You can consume event on raising to prevent it from handling in all other nodes that haven't received event yet.

# How to install

### Cocoapods

Write in podfile:
`pod 'EventsTree'`  
Then execute command in console:
`pod install`

### Carthage

Create Cartfile with line:
`github "DarthRumata/EventsTree"`  
Then execute command in console:
`carthage update`

### Swift Package Manager(can build only for macOS!)

Create Package.swift file(project folders layout should match requirements):  
```
import PackageDescription  
let package = Package(  
  name: “Greeter”,  
  dependencies: [    
    .Package(url: “https://github.com/DarthRumata/EventsTree.git", majorVersion: 0, minor: 1)  
  ]  
)
```  
Then execute command in console:
`swift build`

# How to use
