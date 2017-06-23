__Made in Yalantis__

# Motivation

Imagine that you have iOS application with many screens. Each screen is managed by UIViewController and some data/logic/helper classes. All classes which linked to one screen I call Module. 

We don't discuss communication between classes inside a Module - it can be done pretty easy with delegate/callback/reactive signals.
But what if you need to communicate between different Modules. They can be placed far away from each other in navigation flow.
You can deal with it using NSNotificationCenter, or you can pull callbacks/delegates and etc across the whole application making it overcomplicated.

# Solution

Navigation flow of Modules in app is tree-like structure. And EventNode propose tree-like solution for every such situation(not only Modules but every tree). 
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

pod 'Events'

# How to use
