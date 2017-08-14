//
//  SwipeExpanding.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

/**
 Adopt the `SwipeExpanding` protocol in objects that implement custom appearance of actions during expansion.
 */
public protocol SwipeExpanding {

    /**
     Asks your object for the animation timing parameters.
     
     - parameter buttons: The expansion action button, which includes expanding action plus the remaining actions in the view.
     
     - parameter expanding: The new expansion state.
     
     - parameter otherActionButtons: The other action buttons in the view, not including the action button being expanded.
     */

    func animationTimingParameters(buttons: [UIButton], expanding: Bool) -> SwipeExpansionAnimationTimingParameters
    
    /**
     Tells your object when the expansion state is changing.
     
     - parameter button: The expansion action button.
     
     - parameter expanding: The new expansion state.

     - parameter otherActionButtons: The other action buttons in the view, not including the action button being expanded.
     */
    func actionButton(_ button: UIButton, didChange expanding: Bool, otherActionButtons: [UIButton])
}

/**
 Specifies timing information for the overall expansion animation.
 */
public struct SwipeExpansionAnimationTimingParameters {
    
    /// Returns a `SwipeExpansionAnimationTimingParameters` instance with default animation parameters.
    public static var `default`: SwipeExpansionAnimationTimingParameters { return SwipeExpansionAnimationTimingParameters() }
    
    /// The duration of the expansion animation.
    public var duration: Double
    
    /// The delay before starting the expansion animation.
    public var delay: Double
    
    /**
     Contructs a new `SwipeExpansionAnimationTimingParameters` instance.
     
     - parameter duration: The duration of the animation.
     
     - parameter delay: The delay before starting the expansion animation.
     
     - returns: The new `SwipeExpansionAnimationTimingParameters` instance.
     */
    public init(duration: Double = 0.6, delay: Double = 0) {
        self.duration = duration
        self.delay = delay
    }
}

/**
 A scale and alpha expansion object drives the custom appearance of the effected actions during expansion.
 */
public struct ScaleAndAlphaExpansion: SwipeExpanding {

    /// Returns a `ScaleAndAlphaExpansion` instance with default expansion options.
    public static var `default`: ScaleAndAlphaExpansion { return ScaleAndAlphaExpansion() }
    
    /// The duration of the animation.
    public let duration: Double
    
    /// The scale factor used during animation.
    public let scale: CGFloat
    
    /// The inter-button delay between animations.
    public let interButtonDelay: Double
    
    /**
     Contructs a new `ScaleAndAlphaExpansion` instance.
     
     - parameter duration: The duration of the animation.
     
     - parameter scale: The scale factor used during animation.
     
     - parameter interButtonDelay: The inter-button delay between animations.
     
     - returns: The new `ScaleAndAlphaExpansion` instance.
     */
    public init(duration: Double = 0.15, scale: CGFloat = 0.8, interButtonDelay: Double = 0.1) {
        self.duration = duration
        self.scale = scale
        self.interButtonDelay = interButtonDelay
    }

    /// :nodoc:    
    public func animationTimingParameters(buttons: [UIButton], expanding: Bool) -> SwipeExpansionAnimationTimingParameters {
        var timingParameters = SwipeExpansionAnimationTimingParameters.default
        timingParameters.delay = expanding ? interButtonDelay : 0
        return timingParameters
    }
    
    /// :nodoc:
    public func actionButton(_ button: UIButton, didChange expanding: Bool, otherActionButtons: [UIButton]) {
        let buttons = expanding ? otherActionButtons : otherActionButtons.reversed()
        
        buttons.enumerated().forEach { index, button in
            UIView.animate(withDuration: duration, delay: interButtonDelay * Double(expanding ? index : index + 1), options: [], animations: {
                button.transform = expanding ? .init(scaleX: self.scale, y: self.scale) : .identity
                button.alpha = expanding ? 0.0 : 1.0
            }, completion: nil)
        }
    }
}
