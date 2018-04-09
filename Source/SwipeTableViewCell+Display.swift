//
//  SwipeTableViewCell+Display.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

extension SwipeTableViewCell {
    /// The point at which the origin of the cell is offset from the non-swiped origin.
    public var swipeOffset: CGFloat {
        set { setSwipeOffset(newValue, animated: false) }
        get { return frame.midX - bounds.midX }
    }
    
    /**
     Hides the swipe actions and returns the cell to center.
     
     - parameter animated: Specify `true` to animate the hiding of the swipe actions or `false` to hide it immediately.
     
     - parameter completion: The closure to be executed once the animation has finished. A `Boolean` argument indicates whether or not the animations actually finished before the completion handler was called.     
     */
    public func hideSwipe(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard state == .left || state == .right else { return }
        
        state = .animatingToCenter
        
        let targetCenter = self.targetCenter(active: false)
        
        if animated {
            animate(toOffset: targetCenter) { complete in
                self.reset()
                completion?(complete)
            }
        } else {
            center = CGPoint(x: targetCenter, y: self.center.y)
            reset()
        }
        
        notifyEditingStateChange(active: false)
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
        guard offset != 0 else {
            hideSwipe(animated: animated, completion: completion)
            return
        }
        
        let orientation: SwipeActionsOrientation = offset > 0 ? .left : .right
        let targetState = SwipeState(orientation: orientation)
        
        if state != targetState {
            guard showActionsView(for: orientation) else { return }
            
            tableView?.hideSwipeCell()
            
            state = targetState
        }
        
        let maxOffset = min(bounds.width, abs(offset)) * orientation.scale * -1
        let targetCenter = abs(offset) == CGFloat.greatestFiniteMagnitude ? self.targetCenter(active: true) : bounds.midX + maxOffset
        
        if animated {
            animate(toOffset: targetCenter) { complete in
                completion?(complete)
            }
        } else {
            center.x = targetCenter
        }
    }
}
