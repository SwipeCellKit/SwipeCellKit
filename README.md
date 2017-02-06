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
* Animated expansion when dragging past threshold

# Demo

## Transition Styles

The transition style describes how the action buttons are exposed during the swipe.

#### Border 

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Transition-Border.gif" /></p>

#### Drag 

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Transition-Drag.gif" /></p>

#### Reveal 

<p align="center"><img src="https://raw.githubusercontent.com/jerkoch/SwipeCellKit/develop/Screenshots/Transition-Reveal.gif" /></p>

## Expansion Styles

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

## Credits

Created and maintained by [**@jerkoch**](https://twitter.com/jerkoch).

## License

`SwipeCellKit` is released under an [MIT License][mitLink]. See `LICENSE` for details.

*Please provide attribution, it is greatly appreciated.*

[podLink]:https://cocoapods.org/pods/SwipeCellKit
[docsLink]:http://www.jerkoch.com/SwipeCellKit
[mitLink]:http://opensource.org/licenses/MIT
