//
//  SwipeCellAnimator.swift
//  SwipeCellKit
//
//  Created by Daniel Carmo on 2017-03-22.
//
//

import Foundation

protocol SwipeAnimator {
    /**
     Starts the defined animation
     */
    func startAnimation()
    
    /**
     Stops the current animation
     */
    func stopAnimation()
}

@available(iOS 10, *)
class UIViewPropertyCellAnimator: SwipeAnimator {
    
    weak var cell:SwipeTableViewCell?
    
    var animator: UIViewPropertyAnimator?
    
    init(cell: SwipeTableViewCell, toOffset offset: CGFloat, withInitialVelocity velocity: CGFloat = 0, completion: ((Bool) -> Void)? = nil) {
        self.cell = cell
        self.animator = buildAnimator(toOffset: offset, withInitialVelocity: velocity, completion: completion)
    }
    
    func startAnimation() {
        self.cell?.layoutIfNeeded()
        self.animator?.startAnimation()
    }
    
    func stopAnimation() {
        if animator?.isRunning == true {
            animator?.stopAnimation(true)
        }
    }
    
    private func buildAnimator(toOffset offset: CGFloat,
                               withInitialVelocity velocity: CGFloat = 0,
                               completion: ((Bool) -> Void)? = nil) -> UIViewPropertyAnimator {
        
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
            guard let `cell` = self.cell else { return }
            
            cell.center = CGPoint(x: offset, y: cell.center.y)
            cell.layoutIfNeeded()
        })
        
        if let completion = completion {
            animator.addCompletion { position in
                completion(position == .end)
            }
        }
        
        return animator
    }
}

class UIViewCellAnimator: SwipeAnimator {
    
    weak var cell:SwipeTableViewCell?
    let offset:CGFloat
    let velocity:CGFloat
    let completion:((Bool) -> Void)?
    
    init(cell: SwipeTableViewCell, toOffset offset: CGFloat, withInitialVelocity velocity: CGFloat = 0, completion: ((Bool) -> Void)? = nil) {
        self.cell = cell
        self.offset = offset
        self.velocity = velocity
        self.completion = completion
    }
    
    func startAnimation() {
        guard let `cell` = cell else { return }
        
        var remainingTime = 0.3
        if velocity != 0 {
            let remainingDistance = abs(offset - cell.frame.origin.x)
            remainingTime = Double(min(remainingDistance / velocity, 0.3))
        }
        
        UIView.animate(withDuration: remainingTime,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        guard let `cell` = self.cell else { return }
                        
                        cell.center = CGPoint(x: self.offset, y: cell.center.y)
        },
                       completion: completion)
    }
    
    func stopAnimation() {
        guard let `cell` = cell else { return }
        cell.layer.removeAllAnimations()
    }
}
