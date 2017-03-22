//
//  SwipeExpansionStyle.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

/// Describes the expansion style.  Expansion is the behavior when the cell is swiped past a defined threshold.
public struct SwipeExpansionStyle {
    /// No expansion. Elasticity is applied once all action buttons have been exposed.
    public static var none: SwipeExpansionStyle { return SwipeExpansionStyle() }
    
    /// The default action performs a selection-type behavior. The cell bounces back to its unopened state upon selection and the row remains in the table view.
    public static var selection: SwipeExpansionStyle { return SwipeExpansionStyle(target: .percentage(0.5),
                                                                                  elasticOverscroll: true,
                                                                                  completionAnimation: .bounce) }
    
    /// The default action performs a destructive behavior. The cell is removed from the table view in an animated fashion.
    public static var destructive: SwipeExpansionStyle { return .destructive(with: .fill(.automatic(.delete, timing: .with))) }

    /// The default action performs a destructive behavior after the fill animation completes. The cell is removed from the table view in an animated fashion.
    public static var destructiveAfterFill: SwipeExpansionStyle { return .destructive(with: .fill(.automatic(.delete, timing: .after))) }

    /// The default action performs a fill behavior.
    ///
    /// - note: The action handle must call `SwipeAction.fulfill(stye:)` to resolve the fill expansion.
    public static var fill: SwipeExpansionStyle { return SwipeExpansionStyle(target: .edgeInset(30),
                                                                             additionalTriggers: [.overscroll(30)],
                                                                             completionAnimation: .fill(.manual(timing: .after))) }

    /**
     Returns a `SwipeExpansionStyle` instance for the default action which peforms destructive behavior with the specified completion animation.
     
     - parameter completionAnimation: The expansion animation completion style.
     
     - returns: The new `SwipeExpansionStyle` instance.
     */
    public static func destructive(with completionAnimation: CompletionAnimation) -> SwipeExpansionStyle {
        return SwipeExpansionStyle(target: .edgeInset(30),
                                   additionalTriggers: [.touchThreshold(0.8)],
                                   completionAnimation: completionAnimation)
    }

    /// The relative target expansion threshold. Expansion will occur at the specified value.
    public let target: Target
    
    /// Additional triggers to useful for determining if expansion should occur.
    public let additionalTriggers: [Trigger]
    
    /// Specifies if buttons should expand to fully fill overscroll, or expand at a percentage relative to the overscroll.
    public let elasticOverscroll: Bool
    
    /// Specifies the expansion animation completion style.
    public let completionAnimation: CompletionAnimation
    
    /**
     Contructs a new `SwipeExpansionStyle` instance.
     
     - parameter target: The relative target expansion threshold. Expansion will occur at the specified value.
     
     - parameter additionalTriggers: Additional triggers to useful for determining if expansion should occur.
     
     - parameter elasticOverscroll: Specifies if buttons should expand to fully fill overscroll, or expand at a percentage relative to the overscroll.

     - parameter completionAnimation: Specifies the expansion animation completion style.

     - returns: The new `SwipeExpansionStyle` instance.
     */
    public init(target: Target = .none, additionalTriggers: [Trigger] = [], elasticOverscroll: Bool = false, completionAnimation: CompletionAnimation = .bounce) {
        self.target = target
        self.additionalTriggers = additionalTriggers
        self.elasticOverscroll = elasticOverscroll
        self.completionAnimation = completionAnimation
    }
    
    func shouldExpand(view: Swipeable, gesture: UIPanGestureRecognizer, in superview: UIView) -> Bool {
        guard let actionsView = view.actionsView else { return false }
        
        guard abs(view.frame.minX) >= actionsView.preferredWidth else { return false }
        
        if abs(view.frame.minX) >= target.offset(for: view, in: superview) {
            return true
        }
        
        for trigger in additionalTriggers {
            if trigger.isTriggered(view: view, gesture: gesture, in: superview) {
                return true
            }
        }
        
        return false
    }
    
    func targetOffset(for view: Swipeable, in superview: UIView) -> CGFloat {
        return target.offset(for: view, in: superview)
    }
}

extension SwipeExpansionStyle {    
    /// Describes the relative target expansion threshold. Expansion will occur at the specified value.
    public enum Target {
        /// No target.
        case none
        
        /// The target is specified by a percentage.
        case percentage(CGFloat)
        
        /// The target is specified by a edge inset.
        case edgeInset(CGFloat)
        
        func offset(for view: Swipeable, in superview: UIView) -> CGFloat {
            guard let actionsView = view.actionsView else { return .greatestFiniteMagnitude }
            
            let offset: CGFloat = {
                switch self {
                case .none:
                    return .greatestFiniteMagnitude
                case .percentage(let value):
                    return superview.bounds.width * value
                case .edgeInset(let value):
                    return superview.bounds.width - value
                }
            }()
            
            return max(actionsView.preferredWidth, offset)
        }
    }
    
    /// Describes additional triggers to useful for determining if expansion should occur.
    public enum Trigger {
        /// The trigger is specified by a touch occuring past the supplied percentage in the superview.
        case touchThreshold(CGFloat)
        
        /// The trigger is specified by the distance in points past the fully exposed action view.
        case overscroll(CGFloat)
        
        func isTriggered(view: Swipeable, gesture: UIPanGestureRecognizer, in superview: UIView) -> Bool {
            guard let actionsView = view.actionsView else { return false }
            
            switch self {
            case .touchThreshold(let value):
                let location = gesture.location(in: superview).x
                let locationRatio = (actionsView.orientation == .left ? location : superview.bounds.width - location) / superview.bounds.width
                return locationRatio > value
            case .overscroll(let value):
                return abs(view.frame.minX) > actionsView.preferredWidth + value
            }
        }
    }
    
    /// Describes the expansion animation completion style.
    public enum CompletionAnimation {
        /// The expansion will completely fill the item.
        case fill(FillOptions)
        
        /// The expansion will bounce back from the trigger point and hide the action view, resetting the item.
        case bounce
    }
    
    /// Specifies the options for the fill completion animation.
    public struct FillOptions {
        /// Describes when the action handler with be invoked with respect to the fill animation.
        public enum HandlerInvocationTiming {
            /// The action handler is invoked with the fill animation.
            case with
            
            /// The action handler is invoked after the fill animation completes.
            case after
        }
        
        /**
         Returns a `FillOptions` instance with automatic fulfillemnt.
         
         - parameter style: The fulfillment style describing how expansion should be resolved once the action has been fulfilled.
         
         - parameter timing: The timing which specifies when the action handler with be invoked with respect to the fill animation.
         
         - returns: The new `FillOptions` instance.
         */
        public static func automatic(_ style: ExpansionFulfillmentStyle, timing: HandlerInvocationTiming) -> FillOptions {
            return FillOptions(autoFulFillmentStyle: style, timing: timing)
        }
        
        /**
         Returns a `FillOptions` instance with manual fulfillemnt.
         
         - parameter timing: The timing which specifies when the action handler with be invoked with respect to the fill animation.
         
         - returns: The new `FillOptions` instance.
         */
        public static func manual(timing: HandlerInvocationTiming) -> FillOptions {
            return FillOptions(autoFulFillmentStyle: nil, timing: timing)
        }
        
        /// The fulfillment style describing how expansion should be resolved once the action has been fulfilled.
        public let autoFulFillmentStyle: ExpansionFulfillmentStyle?
        
        /// The timing which specifies when the action handler with be invoked with respect to the fill animation.
        public let timing: HandlerInvocationTiming
    }
}

extension SwipeExpansionStyle.Target: Equatable {
    public static func ==(lhs: SwipeExpansionStyle.Target, rhs: SwipeExpansionStyle.Target) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.percentage(let lhs), .percentage(let rhs)):
            return lhs == rhs
        case (.edgeInset(let lhs), .edgeInset(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension SwipeExpansionStyle.CompletionAnimation: Equatable {
    public static func ==(lhs: SwipeExpansionStyle.CompletionAnimation, rhs: SwipeExpansionStyle.CompletionAnimation) -> Bool {
        switch (lhs, rhs) {
        case (.fill, .fill):
            return true
        case (.bounce, .bounce):
            return true
        default:
            return false
        }
    }
}
