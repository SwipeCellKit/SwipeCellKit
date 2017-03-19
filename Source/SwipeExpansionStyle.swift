//
//  SwipeExpansionStyle.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

/// Describes the expansion style.  Expansion is the behavior when the cell is swiped past a defined threshold.
public struct SwipeExpansionStyle {
    
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
    
    public enum CompletionAnimation {
        case fill(FillOption)
        case bounce
    }
    
    public enum FillOption {
        case withFill(delete: Bool)
        case afterFill(delete: Bool)
    }
    
    /// No expansion. Elasticity is applied once all action buttons have been exposed.
    public static var none: SwipeExpansionStyle { return SwipeExpansionStyle() }
    
    /// The default action performs a selection-type behavior. The cell bounces back to its unopened state upon selection and the row remains in the table view.
    public static var selection: SwipeExpansionStyle { return SwipeExpansionStyle(target: .percentage(0.5),
                                                                                  elasticOverscroll: true,
                                                                                  completionAnimation: .bounce) }
    
    /// The default action performs a destructive behavior. The cell is removed from the table view in an animated fashion.
    public static var destructive: SwipeExpansionStyle { return SwipeExpansionStyle(target: .edgeInset(30),
                                                                                    additionalTriggers: [.touchThreshold(0.8)],
                                                                                    completionAnimation: .fill(.withFill(delete: true))) }
    
    /// The relative target expansion threshold. Expansion will occur at the specified value.
    public let target: Target
    
    /// Additional triggers to useful for determining if expansion should occur.
    public let additionalTriggers: [Trigger]
    
    /// Specifies if buttons should expand to fully fill overscroll, or expand at a percentage relative to the overscroll.
    public let elasticOverscroll: Bool
    
    public let completionAnimation: CompletionAnimation
    
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
        case (.fill(let lhs), .fill(let rhs)):
            return lhs == rhs
        case (.bounce, .bounce):
            return true
        default:
            return false
        }
    }
}

extension SwipeExpansionStyle.FillOption: Equatable {
    public static func ==(lhs: SwipeExpansionStyle.FillOption, rhs: SwipeExpansionStyle.FillOption) -> Bool {
        switch (lhs, rhs) {
        case (.withFill(let lhs), .withFill(let rhs)):
            return lhs == rhs
        case (.afterFill(let lhs), .afterFill(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}
