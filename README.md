# SwipeCellKit

[![Build Status](https://travis-ci.org/jerkoch/SwipeCellKit.svg)](https://travis-ci.org/jerkoch/SwipeCellKit) 
[![Version Status](https://img.shields.io/cocoapods/v/SwipeCellKit.svg)][podLink] 
[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![license MIT](https://img.shields.io/cocoapods/l/SwipeCellKit.svg)][mitLink] 
[![Platform](https://img.shields.io/cocoapods/p/SwipeCellKit.svg)][docsLink] 
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Twitter](https://img.shields.io/badge/twitter-@mkurabi-blue.svg?style=flat)](https://twitter.com/mkurabi)

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

#### Customized

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Transition-Delegate.gif" /></p>

### Expansion Styles

The expansion style describes the behavior when the cell is swiped past a defined threshold.

#### None

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Expansion-None.gif" /></p>

#### Selection

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Expansion-Selection.gif" /></p>

#### Destructive

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Expansion-Destructive.gif" /></p>

#### Customized

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Expansion-Delegate.gif" /></p>

## Requirements

* Swift 4.0
* Xcode 9
* iOS 9.0+

## Installation

#### [CocoaPods](http://cocoapods.org) (recommended)

````ruby
use_frameworks!

# Latest release in CocoaPods
pod 'SwipeCellKit'

# Get the latest on develop
pod 'SwipeCellKit', :git => 'https://github.com/SwipeCellKit/SwipeCellKit.git', :branch => 'develop'
````

#### [Carthage](https://github.com/Carthage/Carthage)

````bash
github "SwipeCellKit/SwipeCellKit"
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
### Transitions

Three built-in transition styles are provided by `SwipeTransitionStyle`:  

* .border: The visible action area is equally divide between all action buttons.
* .drag: The visible action area is dragged, pinned to the cell, with each action button fully sized as it is exposed.
* .reveal: The visible action area sits behind the cell, pinned to the edge of the table view, and is revealed as the cell is dragged aside.

See [Customizing Transitions](https://github.com/SwipeCellKit/SwipeCellKit/blob/develop/Guides/Advanced.md) for more details on customizing button appearance as the swipe is performed.

#### Transition Delegate

Transition for a `SwipeAction` can be observered by setting a `SwipeActionTransitioning` on the `transitionDelegate` property. This allows you to observe what percentage is visible and access to the underlying `UIButton` for that `SwipeAction`. 

### Expansion

Four built-in expansion styles are provided by `SwipeExpansionStyle`:  

* .selection
* .destructive (like Mail.app)
* .destructiveAfterFill (like Mailbox/Tweetbot)
* .fill

Much effort has gone into making `SwipeExpansionStyle` extremely customizable. If these built-in styles do not meet your needs, see [Customizing Expansion](https://github.com/SwipeCellKit/SwipeCellKit/blob/develop/Guides/Advanced.md) for more details on creating custom styles.

The built-in `.fill` expansion style requires manual action fulfillment. This means your action handler must call `SwipeAction.fulfill(style:)` at some point during or after invocation to resolve the fill expansion. The supplied `ExpansionFulfillmentStyle` allows you to delete or reset the cell at some later point (possibly after further user interaction).

The built-in `.destructive`, and `.destructiveAfterFill` expansion styles are configured to automatically perform row deletion when the action handler is invoked (automatic fulfillment).  Your deletion behavior may require coordination with other row animations (eg. inside `beginUpdates` and `endUpdates`). In this case, you can easily create a custom `SwipeExpansionStyle` which requires manual fulfillment to trigger deletion:

````swift
var options = SwipeTableOptions()
options.expansionStyle = .destructive(automaticallyDelete: false)
````

> **NOTE**: You must call `SwipeAction.fulfill(with style:)` at some point while/after your action handler is invoked to trigger deletion. Do not call `deleteRows` directly.

````swift
let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in
    // Update model
    self.emails.remove(at: indexPath.row)
    action.fulfill(with: .delete)
}
````

## Advanced 

See the [Advanced Guide](https://github.com/SwipeCellKit/SwipeCellKit/blob/develop/Guides/Advanced.md) for more details on customization.

## Credits

Maintained by [**@mkurabi**](https://twitter.com/mkurabi).

## Showcase

We're interested in knowing [who's using *SwipeCellKit*](https://github.com/SwipeCellKit/SwipeCellKit/blob/develop/SHOWCASE.md) in their app. Please submit a pull request to add your app! 

## License

`SwipeCellKit` is released under an [MIT License][mitLink]. See `LICENSE` for details.

*Please provide attribution, it is greatly appreciated.*

[podLink]:https://cocoapods.org/pods/SwipeCellKit
[docsLink]:https://swipecellkit.github.io/SwipeCellKit/
[mitLink]:http://opensource.org/licenses/MIT
