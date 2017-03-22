//
//  SwipeCellAnimator.swift
//  SwipeCellKit
//
//  Created by Daniel Carmo on 2017-03-22.
//
//

import Foundation

protocol SwipeTableViewCellAnimator {
    /**
     Asks the delegate for the actions to display in response to a swipe in the specified row.
     
     - parameter offset: The end offset x value of the animation
     
     - parameter velocity: The speed at which the animation is to pick up from.
     
     - parameter completion: The block indicating when the animation has completed
     */
    func animate(toOffset offset: CGFloat, withInitialVelocity velocity: CGFloat, completion: ((Bool) -> Void)?)
    
    /**
     Stops the animation at the current position
     */
    func stop()
}

@available(iOS 10, *)
class UIViewPropertyAnimatorSwipeTableViewCellAnimator: SwipeTableViewCellAnimator {
    
    weak var cell:SwipeTableViewCell?
    
    var animator: UIViewPropertyAnimator?
    
    init(cell: SwipeTableViewCell) {
        self.cell = cell
    }
    
    func animate(toOffset offset: CGFloat, withInitialVelocity velocity: CGFloat = 0, completion: ((Bool) -> Void)? = nil) {
        
        guard let `cell` = cell else { return }
        
        stop()
        
        cell.layoutIfNeeded()
        
        let animator: UIViewPropertyAnimator = {
            if velocity != 0 {
                let velocity = CGVector(dx: velocity, dy: velocity)
                let parameters = UISpringTimingParameters(mass: 1.0, stiffness: 100, damping: 18, initialVelocity: velocity)
                return UIViewPropertyAnimator(duration: 0.0, timingParameters: parameters)
            } else {
                return UIViewPropertyAnimator(duration: 0.7, dampingRatio: 1.0)
            }
        }()
        
        animator.addAnimations({
            cell.center = CGPoint(x: offset, y: cell.center.y)
            
            cell.layoutIfNeeded()
        })
        
        if let completion = completion {
            animator.addCompletion { position in
                completion(position == .end)
            }
        }
        
        self.animator = animator
        self.animator?.startAnimation()
    }
    
    func stop() {
        if animator?.isRunning == true {
            animator?.stopAnimation(true)
        }
    }
}

class UIViewAnimatorSwipeTableViewCellAnimator: SwipeTableViewCellAnimator {
    
    weak var cell:SwipeTableViewCell?
    
    init(cell: SwipeTableViewCell) {
        self.cell = cell
    }
    
    func animate(toOffset offset: CGFloat, withInitialVelocity velocity: CGFloat = 0, completion: ((Bool) -> Void)? = nil) {
        
        guard let `cell` = cell else { return }
        
        var remainingTime = 0.7
        if velocity != 0 {
            let remainingDistance = abs(offset - cell.frame.origin.x)
            remainingTime = Double(min(remainingDistance / velocity, 0.3))
        }
        
        UIView.animate(withDuration: remainingTime, delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        cell.center = CGPoint(x: offset, y: cell.center.y)
        },
                       completion: completion)
    }
    
    func stop() {
        guard let `cell` = cell else { return }
        cell.layer.removeAllAnimations()
    }
}
