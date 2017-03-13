//
//  SwipeActionsView.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

protocol SwipeActionsViewDelegate: class {
    func swipeActionsView(_ swipeActionsView: SwipeActionsView, didSelect action: SwipeAction)
}

class SwipeActionsView: UIView {
    weak var delegate: SwipeActionsViewDelegate?
    
    let transitionLayout: SwipeTransitionLayout
    var layoutContext: ActionsViewLayoutContext
    
    var expansionAnimator: Any?
    
    var expansionDelegate: SwipeExpanding? {
        return options.expansionDelegate ?? (expandableAction?.hasBackgroundColor == false ? ScaleAndAlphaExpansion.default : nil)
    }

    let orientation: SwipeActionsOrientation
    let actions: [SwipeAction]
    let options: SwipeTableOptions
    
    var buttons: [SwipeActionButton] = []
    
    var minimumButtonWidth: CGFloat = 0
    var maximumImageHeight: CGFloat {
        return actions.reduce(0, { initial, next in max(initial, next.image?.size.height ?? 0) })
    }
    
    var visibleWidth: CGFloat = 0 {
        didSet {
            let preLayoutVisibleWidths = transitionLayout.visibleWidthsForViews(with: layoutContext)

            layoutContext = ActionsViewLayoutContext.newContext(for: self)
            
            transitionLayout.container(view: self, didChangeVisibleWidthWithContext: layoutContext)
            
            setNeedsLayout()
            layoutIfNeeded()
            
            notifyVisibleWidthChanged(oldWidths: preLayoutVisibleWidths,
                                      newWidths: transitionLayout.visibleWidthsForViews(with: layoutContext))
        }
    }
 
    var preferredWidth: CGFloat {
        return minimumButtonWidth * CGFloat(actions.count)
    }

    var contentSize: CGSize {
        if options.expansionStyle != .selection || visibleWidth < preferredWidth {
            return CGSize(width: visibleWidth, height: bounds.height)
        } else {
            let scrollRatio = max(0, visibleWidth - preferredWidth)
            return CGSize(width: preferredWidth + (scrollRatio * 0.25), height: bounds.height)
        }
    }
    
    var expanded: Bool = false {
        didSet {
            guard oldValue != expanded else { return }

            if #available(iOS 10, *), let expansionAnimator = self.expansionAnimator as? UIViewPropertyAnimator {
                let timingParameters = expansionDelegate?.animationTimingParameters(buttons: buttons.reversed(), expanding: expanded)
                
                if expansionAnimator.isRunning == true {
                    expansionAnimator.stopAnimation(true)
                }
                
                self.expansionAnimator = UIViewPropertyAnimator(duration: timingParameters?.duration ?? 0.6, dampingRatio: 1.0) {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }
                
                (self.expansionAnimator as! UIViewPropertyAnimator).startAnimation(afterDelay: timingParameters?.delay ?? 0)
            }

            notifyExpansion(expanded: expanded)
        }
    }
    
    var expandableAction: SwipeAction? {
        return options.expansionStyle != .none ? actions.last : nil
    }
    
    init(maxSize: CGSize, options: SwipeTableOptions, orientation: SwipeActionsOrientation, actions: [SwipeAction]) {
        self.options = options
        self.orientation = orientation
        self.actions = actions.reversed()
        
        switch options.transitionStyle {
        case .border:
            transitionLayout = BorderTransitionLayout()
        case .reveal:
            transitionLayout = RevealTransitionLayout()
        default:
            transitionLayout = DragTransitionLayout()
        }
        
        self.layoutContext = ActionsViewLayoutContext(numberOfActions: actions.count, orientation: orientation)
        
        super.init(frame: .zero)
        
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = options.backgroundColor ?? #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        
        buttons = addButtons(for: self.actions, withMaximum: maxSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addButtons(for actions: [SwipeAction], withMaximum size: CGSize) -> [SwipeActionButton] {
        let buttons: [SwipeActionButton] = actions.map({ action in
            let actionButton = SwipeActionButton(action: action)
            actionButton.addTarget(self, action: #selector(actionTapped(button:)), for: .touchUpInside)
            actionButton.spacing = options.buttonSpacing ?? 8
            actionButton.contentEdgeInsets = buttonEdgeInsets(fromOptions: options)
            return actionButton
        })
        
        let maximum = options.maximumButtonWidth ?? (size.width - 30) / CGFloat(actions.count)
        minimumButtonWidth = buttons.reduce(options.minimumButtonWidth ?? 74, { initial, next in max(initial, next.preferredWidth(maximum: maximum)) })
        
        buttons.enumerated().forEach { (index, button) in
            let action = actions[index]
            let frame = CGRect(origin: .zero, size: CGSize(width: size.width * 2, height: size.height))
            let wrapperView = SwipeActionButtonWrapperView(frame: frame, action: action, orientation: orientation, contentWidth: minimumButtonWidth)
            wrapperView.addSubview(button)
            
            if let effect = action.backgroundEffect {
                let effectView = UIVisualEffectView(effect: effect)
                effectView.frame = wrapperView.frame
                effectView.contentView.addSubview(wrapperView)
                addSubview(effectView)
            } else {
                addSubview(wrapperView)
            }
            
            button.frame = wrapperView.contentRect
            button.maximumImageHeight = maximumImageHeight
            button.verticalAlignment = options.buttonVerticalAlignment
            button.shouldHighlight = action.hasBackgroundColor
        }
        
        return buttons
    }
    
    func actionTapped(button: SwipeActionButton) {
        guard let index = buttons.index(of: button) else { return }

        delegate?.swipeActionsView(self, didSelect: actions[index])
    }
    
    func buttonEdgeInsets(fromOptions options: SwipeTableOptions) -> UIEdgeInsets {
        let padding = options.buttonPadding ?? 8
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func notifyVisibleWidthChanged(oldWidths: [CGFloat], newWidths: [CGFloat]) {
        DispatchQueue.main.async {
            oldWidths.enumerated().forEach { index, oldWidth in
                let newWidth = newWidths[index]
                
                if oldWidth != newWidth {
                    let context = SwipeActionTransitioningContext(actionIdentifier: self.actions[index].identifier,
                                                             button: self.buttons[index],
                                                             newPercentVisible: newWidth / self.minimumButtonWidth,
                                                             oldPercentVisible: oldWidth / self.minimumButtonWidth,
                                                             wrapperView: self.subviews[index])
                    
                    self.actions[index].transitionDelegate?.didTransition(with: context)
                }
            }
        }
    }
    
    func notifyExpansion(expanded: Bool) {
        guard let expandedButton = buttons.last else { return }

        expansionDelegate?.actionButton(expandedButton, didChange: expanded, otherActionButtons: buttons.dropLast().reversed())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for subview in subviews.enumerated() {
            transitionLayout.layout(view: subview.element, atIndex: subview.offset, with: layoutContext)
        }
        
        if expanded {
            subviews.last?.frame.origin.x = 0 + bounds.origin.x
        }
    }
}

class SwipeActionButtonWrapperView: UIView {
    let contentRect: CGRect
    
    init(frame: CGRect, action: SwipeAction, orientation: SwipeActionsOrientation, contentWidth: CGFloat) {
        switch orientation {
        case .left:
            contentRect = CGRect(x: frame.width - contentWidth, y: 0, width: contentWidth, height: frame.height)
        case .right:
            contentRect = CGRect(x: 0, y: 0, width: contentWidth, height: frame.height)
        }
        
        super.init(frame: frame)
        
        configureBackgroundColor(with: action)
    }
    
    func configureBackgroundColor(with action: SwipeAction) {
        guard action.hasBackgroundColor else { return }
        
        if let backgroundColor = action.backgroundColor {
            self.backgroundColor = backgroundColor
        } else {
            switch action.style {
            case .destructive:
                backgroundColor = #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
            default:
                backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
