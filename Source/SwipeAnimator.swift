//
//  SwipeCellAnimator.swift
//  SwipeCellKit
//
//  Created by Daniel Carmo on 2017-03-22.
//
//

import Foundation

protocol SwipeAnimator {
    
    init(duration: TimeInterval,
         mass: CGFloat,
         stiffness: CGFloat,
         damping: CGFloat,
         dampingRatio ratio: CGFloat,
         initialVelocity velocity: CGFloat)
    
    func addAnimations(_ animation: @escaping () -> Swift.Void)
    
    func addCompletion(_ completion: @escaping (Bool) -> Swift.Void)
    
    /**
     Starts the defined animation
     */
    func startAnimation()
    
    /**
     Stops the current animation
     */
    func stopAnimation(on view:UIView?)
}

@available(iOS 10, *)
class UIViewPropertyCellAnimator: SwipeAnimator {
    
    var animator: UIViewPropertyAnimator?
    
    required init(duration: TimeInterval,
                  mass: CGFloat,
                  stiffness: CGFloat,
                  damping: CGFloat,
                  dampingRatio ratio: CGFloat,
                  initialVelocity velocity: CGFloat = 0) {
        
        if velocity != 0 {
            let velocity = CGVector(dx: velocity, dy: velocity)
            let parameters = UISpringTimingParameters(mass: mass,
                                                      stiffness: stiffness,
                                                      damping: damping,
                                                      initialVelocity: velocity)
            
            self.animator = UIViewPropertyAnimator(duration: 0.0, timingParameters: parameters)
            
        } else {
            self.animator = UIViewPropertyAnimator(duration: duration, dampingRatio: ratio)
        }
    }
    
    func addAnimations(_ animation: @escaping () -> Void) {
        self.animator?.addAnimations(animation)
    }
    
    func addCompletion(_ completion: @escaping (Bool) -> Void) {
        self.animator?.addCompletion { (position) in
            completion(position == .end)
        }
    }
    
    func startAnimation() {
        self.animator?.startAnimation()
    }
    
    func stopAnimation(on view:UIView? = nil) {
        if animator?.isRunning == true {
            animator?.stopAnimation(true)
        }
    }
}

class UIViewCellAnimator: SwipeAnimator {
    
    let duration:TimeInterval
    let damping:CGFloat
    let velocity:CGFloat
    
    var animation:(() -> Swift.Void)?
    var completion:((Bool) -> Swift.Void)?
    
    // Maybe I can use the extra mass/stiffness/ratio in some calculation for the ratio?
    required init(duration: TimeInterval,
                  mass: CGFloat = 0,
                  stiffness: CGFloat = 0,
                  damping: CGFloat,
                  dampingRatio ratio: CGFloat = 0,
                  initialVelocity velocity: CGFloat) {
        
        self.duration = duration
        self.damping = damping
        self.velocity = velocity
    }
    
    func addAnimations(_ animation: @escaping () -> Void) {
        self.animation = animation
    }
    
    func addCompletion(_ completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }
    
    func startAnimation() {
        guard let animation = animation else { return }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: velocity,
                       options: .curveEaseInOut,
                       animations: animation,
                       completion: completion)
    }
    
    func stopAnimation(on view:UIView?) {
        guard let view = view else { return }
        // Can't do this without the cell instance to stop the animations on the layer
        view.layer.removeAllAnimations()
    }
}
