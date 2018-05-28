//
//  SwipeCollectionViewCell+Display.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

extension SwipeCollectionViewCell {
    /// The point at which the origin of the cell is offset from the non-swiped origin.
    public var swipeOffset: CGFloat {
        set { setSwipeOffset(newValue, animated: false) }
        get { return contentView.frame.midX - bounds.midX }
    }
    
    /**
     Hides the swipe actions and returns the cell to center.
     
     - parameter animated: Specify `true` to animate the hiding of the swipe actions or `false` to hide it immediately.
     
     - parameter completion: The closure to be executed once the animation has finished. A `Boolean` argument indicates whether or not the animations actually finished before the completion handler was called.
     */
    public func hideSwipe(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        swipeController.hideSwipe(animated: animated, completion: completion)
    }
    
    /**
     Shows the swipe actions for the specified orientation.
     
     - parameter orientation: The side of the cell on which to show the swipe actions.
     
     - parameter animated: Specify `true` to animate the showing of the swipe actions or `false` to show them immediately.
     
     - parameter completion: The closure to be executed once the animation has finished. A `Boolean` argument indicates whether or not the animations actually finished before the completion handler was called.
     */
    public func showSwipe(orientation: SwipeActionsOrientation, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        setSwipeOffset(.greatestFiniteMagnitude * orientation.scale * -1,
                       animated: animated,
                       completion: completion)
    }
    
    /**
     The point at which the origin of the cell is offset from the non-swiped origin.
     
     - parameter offset: A point (expressed in points) that is offset from the non-swiped origin.
     
     - parameter animated: Specify `true` to animate the transition to the new offset, `false` to make the transition immediate.
     
     - parameter completion: The closure to be executed once the animation has finished. A `Boolean` argument indicates whether or not the animations actually finished before the completion handler was called.
     */
    public func setSwipeOffset(_ offset: CGFloat, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        swipeController.setSwipeOffset(offset, animated: animated, completion: completion)
    }
}
