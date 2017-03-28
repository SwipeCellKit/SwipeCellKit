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
     Initializer used for creating a spring animation
     
     - parameter duration: The duration of the animation
     
     - parameter mass: The mass of the object to animate
     
     - parameter stiffness: How rigid the object is as it moves through the animation
     
     - parameter damping: Dampening force applied to the animating object
     
     - parameter ratio: The dampening ratio of the animating object
     
     - parameter velocity: The initial velocity of the object before applying the spring animation
     */
    init(duration: TimeInterval,
         mass: CGFloat,
         stiffness: CGFloat,
         damping: CGFloat,
         dampingRatio ratio: CGFloat,
         initialVelocity velocity: CGFloat)
    
    /**
     The animation to be run by the SwipeAnimator
     
     - parameter animation: The closure to be executed by the animator
     */
    func addAnimations(_ animation: @escaping () -> Swift.Void)
    
    /**
     Completion handler for the animation that is going to be started
     
     - parameter completion: The closure to be execute on completion of the animator
     */
    func addCompletion(_ completion: @escaping (Bool) -> Swift.Void)
    
    /**
     Starts the defined animation
     */
    func startAnimation()
    
    /**
     Stops the current animation
     
     - parameter view: Required parameter for stopping animations for iOS 9 or less
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
        view.layer.removeAllAnimations()
    }
}
