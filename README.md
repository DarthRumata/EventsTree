# EventNode
Library for sending and handling events for iOS/macOS/tvOS/watchOS applications

# Motivation

Imagine that you have iOS application with many screens. Each screen is managed by UIViewController and some data/logic/helper classes. All classes which linked to one screen I call Module. 

We don't discuss communication between classes inside a Module - it can be done pretty easy with delegate/callback/reactive signals.
But what if you need to communicate between different Modules. They can be placed far away from each other in navigation flow.
You can deal with it using NSNotificationCenter, or you can pull callbacks/delegates and etc across the whole application making it overcomplicated.

# How to install

# How to use
