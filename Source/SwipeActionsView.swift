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
    
    var feedbackGenerator: SwipeFeedback
    
    var expansionAnimator: SwipeAnimator?
    
    var expansionDelegate: SwipeExpanding? {
        return options.expansionDelegate ?? (expandableAction?.hasBackgroundColor == false ? ScaleAndAlphaExpansion.default : nil)
    }

    weak var safeAreaInsetView: UIView?
    let orientation: SwipeActionsOrientation
    let actions: [SwipeAction]
    let options: SwipeOptions
    
    var buttons: [SwipeActionButton] = []
    
    var minimumButtonWidth: CGFloat = 0
    var maximumImageHeight: CGFloat {
        return actions.reduce(0, { initial, next in max(initial, next.image?.size.height ?? 0) })
    }
    
    var safeAreaMargin: CGFloat {
        guard #available(iOS 11, *) else { return 0 }
        guard let scrollView = self.safeAreaInsetView else { return 0 }
        return orientation == .left ? scrollView.safeAreaInsets.left : scrollView.safeAreaInsets.right
    }

    var visibleWidth: CGFloat = 0 {
        didSet {
            // If necessary, adjust for safe areas
            visibleWidth = max(0, visibleWidth - safeAreaMargin)

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
        return minimumButtonWidth * CGFloat(actions.count) + safeAreaMargin
    }

    var contentSize: CGSize {
        if options.expansionStyle?.elasticOverscroll != true || visibleWidth < preferredWidth {
            return CGSize(width: visibleWidth, height: bounds.height)
        } else {
            let scrollRatio = max(0, visibleWidth - preferredWidth)
            return CGSize(width: preferredWidth + (scrollRatio * 0.25), height: bounds.height)
        }
    }
    
    private(set) var expanded: Bool = false
    
    var expandableAction: SwipeAction? {
        return options.expansionStyle != nil ? actions.last : nil
    }
    
    init(contentEdgeInsets: UIEdgeInsets,
         maxSize: CGSize,
         safeAreaInsetView: UIView,
         options: SwipeOptions,
         orientation: SwipeActionsOrientation,
         actions: [SwipeAction]) {
        
        self.safeAreaInsetView = safeAreaInsetView
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
        
        feedbackGenerator = SwipeFeedback(style: .light)
        feedbackGenerator.prepare()
        
        super.init(frame: .zero)
        
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = options.backgroundColor ?? #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        
        buttons = addButtons(for: self.actions, withMaximum: maxSize, contentEdgeInsets: contentEdgeInsets)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addButtons(for actions: [SwipeAction], withMaximum size: CGSize, contentEdgeInsets: UIEdgeInsets) -> [SwipeActionButton] {
        let buttons: [SwipeActionButton] = actions.map({ action in
            let actionButton = SwipeActionButton(action: action)
            actionButton.addTarget(self, action: #selector(actionTapped(button:)), for: .touchUpInside)
            actionButton.autoresizingMask = [.flexibleHeight, orientation == .right ? .flexibleRightMargin : .flexibleLeftMargin]
            actionButton.spacing = options.buttonSpacing ?? 8
            actionButton.contentEdgeInsets = buttonEdgeInsets(fromOptions: options)
            return actionButton
        })
        
        let maximum = options.maximumButtonWidth ?? (size.width - 30) / CGFloat(actions.count)
        let minimum = options.minimumButtonWidth ?? min(maximum, 74)
        minimumButtonWidth = buttons.reduce(minimum, { initial, next in max(initial, next.preferredWidth(maximum: maximum)) })
        
        
        buttons.enumerated().forEach { (index, button) in
            let action = actions[index]
            let frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.height))
            let wrapperView = SwipeActionButtonWrapperView(frame: frame, action: action, orientation: orientation, contentWidth: minimumButtonWidth)
            wrapperView.translatesAutoresizingMaskIntoConstraints = false
            wrapperView.addSubview(button)
            
            if let effect = action.backgroundEffect {
                let effectView = UIVisualEffectView(effect: effect)
                effectView.frame = wrapperView.frame
                effectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                effectView.contentView.addSubview(wrapperView)
                addSubview(effectView)
            } else {
                addSubview(wrapperView)
            }
            
            button.frame = wrapperView.contentRect
            button.maximumImageHeight = maximumImageHeight
            button.verticalAlignment = options.buttonVerticalAlignment
            button.shouldHighlight = action.hasBackgroundColor
            
            wrapperView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            wrapperView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            let topConstraint = wrapperView.topAnchor.constraint(equalTo: topAnchor, constant: contentEdgeInsets.top)
            topConstraint.priority = contentEdgeInsets.top == 0 ? .required : .defaultHigh
            topConstraint.isActive = true
            
            let bottomConstraint = wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * contentEdgeInsets.bottom)
            bottomConstraint.priority = contentEdgeInsets.bottom == 0 ? .required : .defaultHigh
            bottomConstraint.isActive = true
            
            if contentEdgeInsets != .zero {
                let heightConstraint = wrapperView.heightAnchor.constraint(greaterThanOrEqualToConstant: button.intrinsicContentSize.height)
                heightConstraint.priority = .required
                heightConstraint.isActive = true
            }
        }
        return buttons
    }
    
    @objc func actionTapped(button: SwipeActionButton) {
        guard let index = buttons.firstIndex(of: button) else { return }

        delegate?.swipeActionsView(self, didSelect: actions[index])
    }
    
    func buttonEdgeInsets(fromOptions options: SwipeOptions) -> UIEdgeInsets {
        let padding = options.buttonPadding ?? 8
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func setExpanded(expanded: Bool, feedback: Bool = false) {
        guard self.expanded != expanded else { return }
        
        self.expanded = expanded
        
        if feedback {
            feedbackGenerator.impactOccurred()
            feedbackGenerator.prepare()
        }
        
        let timingParameters = expansionDelegate?.animationTimingParameters(buttons: buttons.reversed(), expanding: expanded)
        
        if expansionAnimator?.isRunning == true {
            expansionAnimator?.stopAnimation(true)
        }
        
        if #available(iOS 10, *) {
            expansionAnimator = UIViewPropertyAnimator(duration: timingParameters?.duration ?? 0.6, dampingRatio: 1.0)
        } else {
            expansionAnimator = UIViewSpringAnimator(duration: timingParameters?.duration ?? 0.6,
                                                     damping: 1.0,
                                                     initialVelocity: 1.0)
        }
        
        expansionAnimator?.addAnimations {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        
        expansionAnimator?.startAnimation(afterDelay: timingParameters?.delay ?? 0)
        
        notifyExpansion(expanded: expanded)
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
    
    func createDeletionMask() -> UIView {
        let mask = UIView(frame: CGRect(x: min(0, frame.minX), y: 0, width: bounds.width * 2, height: bounds.height))
        mask.backgroundColor = UIColor.white
        return mask
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
    var actionBackgroundColor: UIColor?
    
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let actionBackgroundColor = self.actionBackgroundColor, let context = UIGraphicsGetCurrentContext() {
            actionBackgroundColor.setFill()
            context.fill(rect);
        }
    }
    
    func configureBackgroundColor(with action: SwipeAction) {
        guard action.hasBackgroundColor else {
            isOpaque = false
            return
        }
        
        if let backgroundColor = action.backgroundColor {
            actionBackgroundColor = backgroundColor
        } else {
            switch action.style {
            case .destructive:
                actionBackgroundColor = #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
            default:
                actionBackgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
