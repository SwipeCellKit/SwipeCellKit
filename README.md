# SwipeCellKit

[![Build Status](https://travis-ci.org/jerkoch/SwipeCellKit.svg)](https://travis-ci.org/jerkoch/SwipeCellKit) 
[![Version Status](https://img.shields.io/cocoapods/v/SwipeCellKit.svg)][podLink] 
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![license MIT](https://img.shields.io/cocoapods/l/SwipeCellKit.svg)][mitLink] 
[![Platform](https://img.shields.io/cocoapods/p/SwipeCellKit.svg)][docsLink] 
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Twitter](https://img.shields.io/badge/twitter-@jerkoch-blue.svg?style=flat)](https://twitter.com/jerkoch)

*Swipeable UITableViewCell based on the stock Mail.app, implemented in Swift.*

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Hero.gif" /></p>

## About

A swipeable UITableViewCell with support for:

* Left and right swipe actions
* Action buttons with: *text only, text + image, image only*
* Haptic Feedback
* Customizable transitions: *Border, Drag, and Reveal*
* Customizable action button behavior during swipe
* Animated expansion when dragging past threshold
* Customizable expansion animations
* Accessibility

## Background

Check out my [blog post](https://jerkoch.com/2017/02/07/swiper-no-swiping.html) on how *SwipeCellKit* came to be.

## Demo

### Transition Styles

The transition style describes how the action buttons are exposed during the swipe.

#### Border 

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Transition-Border.gif" /></p>

#### Drag 

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Transition-Drag.gif" /></p>

#### Reveal 

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Transition-Reveal.gif" /></p>

### Expansion Styles

The expansion style describes the behavior when the cell is swiped past a defined threshold.

#### None

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Expansion-None.gif" /></p>

#### Selection

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Expansion-Selection.gif" /></p>

#### Destructive

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Expansion-Destructive.gif" /></p>

## Requirements

* Swift 3.0
* Xcode 8
* iOS 10.0+

## Installation

#### [CocoaPods](http://cocoapods.org) (recommended)

````ruby
use_frameworks!

# Latest release in CocoaPods
pod 'SwipeCellKit'

# Get the latest on develop
pod 'SwipeCellKit', :git => 'https://github.com/jerkoch/SwipeCellKit.git', :branch => 'develop'
````

#### [Carthage](https://github.com/Carthage/Carthage)

````bash
github "jerkoch/SwipeCellKit"
````

## Documentation

Read the [docs][docsLink]. Generated with [jazzy](https://github.com/realm/jazzy). Hosted by [GitHub Pages](https://pages.github.com).

## Usage

Set the `delegate` property on `SwipeTableViewCell`:

````swift
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
    cell.delegate = self
    return cell
}
````

Adopt the `SwipeTableViewCellDelegate` protocol:

````swift
func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }

    let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
        // handle action by updating model with deletion
    }

    // customize the action appearance
    deleteAction.image = UIImage(named: "delete")

    return [deleteAction]
}
````

Optionally, you can implement the `editActionsOptionsForRowAt` method to customize the behavior of the swipe actions:

````swift    
func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
    var options = SwipeTableOptions()
    options.expansionStyle = .destructive
    options.transitionStyle = .border
    return options
}
````

### Customizing Transitions

You can customize the transition behavior of individual actions by assigning a `transitionDelegate` to the `SwipeAction` type. 

The provided `ScaleTransition` type monitors the action button's visibility as it crosses the `threshold`, and animates between `initialScale` and `identity`.  This provides a "pop-like" effect as the action buttons are exposed more than 50% of their target width. 

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Transition-Delegate.gif" /></p>

````swift
let action = SwipeAction(style: .default, title: "More") { action, indexPath in return }
action.transitionDelegate = ScaleTransition.default
````

The `ScaleTransition` type provides a static `default` configuration, but it can also be initiantiated with custom parameters to suit your needs.

You can also easily provide your own completely custom transition behavior by adopting the `SwipeActionTransitioning` protocol.  The supplied `SwipeActionTransitioningContext` to the delegate methods reflect the current swipe state as the gesture is performed.

### Customizing Expansion

It is also possible to customize the expansion behavior by assigning a `expansionDelegate` to the `SwipeTableOptions` type. The delegate is invoked during the (un)expansion process and allows you to customize the display of the action being expanded, as well as the other actions in the view. 

The provided `ScaleAndAlphaExpansion` type is useful for actions with clear backgrounds. When expansion occurs, the `ScaleAndAlphaExpansion` type automatically scales and fades the remaining actions in and out of the view. By default, if the expanded action has a clear background, the default `ScaleAndAlphaExpansion` will be automatically applied by the system.

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Expansion-Delegate.gif" /></p>

````swift
var options = SwipeTableOptions()
options.expansionDelegate = ScaleAndAlphaExpansion.default
````

The `ScaleAndAlphaExpansion` type provides a static `default` configuration, but it can also be instantiated with custom parameters to suit your needs.

You can also provide your own completely custom expansion behavior by adopting the `SwipeExpanding` protocol. The protocol allows you to customize the animation timing parameters prior to initiating the (un)expansion animation, as well as customizing the action during (un)expansion.

## Credits

Created and maintained by [**@jerkoch**](https://twitter.com/jerkoch).

## License

`SwipeCellKit` is released under an [MIT License][mitLink]. See `LICENSE` for details.

*Please provide attribution, it is greatly appreciated.*

[podLink]:https://cocoapods.org/pods/SwipeCellKit
[docsLink]:http://www.jerkoch.com/SwipeCellKit
[mitLink]:http://opensource.org/licenses/MIT
