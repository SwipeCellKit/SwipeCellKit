//
//  SwipeController.swift
//  SwipeCellKit
//
//  Created by Mohammad Kurabi on 5/19/18.
//

import Foundation

protocol SwipeControllerDelegate: class {
    
    func swipeController(_ controller: SwipeController, canBeginEditingSwipeableFor orientation: SwipeActionsOrientation) -> Bool
    
    func swipeController(_ controller: SwipeController, editActionsForSwipeableFor orientation: SwipeActionsOrientation) -> [SwipeAction]?
    
    func swipeController(_ controller: SwipeController, editActionsOptionsForSwipeableFor orientation: SwipeActionsOrientation) -> SwipeOptions
    
    func swipeController(_ controller: SwipeController, willBeginEditingSwipeableFor orientation: SwipeActionsOrientation)
    
    func swipeController(_ controller: SwipeController, didEndEditingSwipeableFor orientation: SwipeActionsOrientation)
    
    func swipeController(_ controller: SwipeController, didDeleteSwipeableAt indexPath: IndexPath)
    
    func swipeController(_ controller: SwipeController, visibleRectFor scrollView: UIScrollView) -> CGRect?
    
}

class SwipeController: NSObject {
    
    weak var swipeable: (UIView & Swipeable)?
    weak var actionsContainerView: UIView?
    
    weak var delegate: SwipeControllerDelegate?
    weak var scrollView: UIScrollView?
    
    var animator: SwipeAnimator?
    
    let elasticScrollRatio: CGFloat = 0.4
    
    var originalCenter: CGFloat = 0
    var scrollRatio: CGFloat = 1.0
    var originalLayoutMargins: UIEdgeInsets = .zero

    /// If the user swipes quickly or beyond a certain distance threshold, you may want to force the swipe through gesture
    /// Every time a pan gesture finishes, this block is called.
    /// If this block returns true, it will not open the menu and instead trigger a swipe through animation.
    public var customActionTrigger: ((UIPanGestureRecognizer)->Bool)? = nil

    /// If the user swipes back quickly (as if trying to close the menu), by default, it will trigger a swipe through animation.
    /// Implement this method if you want to instead base it off some other factor (such as velocity)
    /// If this block returns true, it will close the swipe cell and not trigger an action
    /// This is only called if the user is swiping in a close direction
    public var forceMenuCloseTrigger: ((UIPanGestureRecognizer)->Bool)? = nil
    
    public lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    init(swipeable: UIView & Swipeable, actionsContainerView: UIView) {
        self.swipeable = swipeable
        self.actionsContainerView = actionsContainerView
        
        super.init()
        
        configure()
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        guard let target = actionsContainerView, var swipeable = self.swipeable else { return }

        if let cell = swipeable as? SwipeTableViewCell {
            guard cell.isEditing == false && cell.pseudoEditing == false else { return }
        }
        
        let velocity = gesture.velocity(in: target)
        
        if delegate?.swipeController(self, canBeginEditingSwipeableFor: velocity.x > 0 ? .left : .right) == false {
            return
        }
        
        switch gesture.state {
        case .began:
            if let swipeable = scrollView?.swipeables.first(where: { $0.state == .dragging }) as? UIView, swipeable != self.swipeable {
                return
            }
            
            stopAnimatorIfNeeded()
            
            originalCenter = target.center.x
            
            if swipeable.state == .center || swipeable.state == .animatingToCenter {
                let orientation: SwipeActionsOrientation = velocity.x > 0 ? .left : .right
                
                showActionsView(for: orientation)
            }
        case .changed:
            guard let actionsView = swipeable.actionsView, let actionsContainerView = self.actionsContainerView else { return }
            guard swipeable.state.isActive else { return }
            
            if swipeable.state == .animatingToCenter {
                let swipedCell = scrollView?.swipeables.first(where: { $0.state == .dragging || $0.state == .left || $0.state == .right }) as? UIView
                if let swipedCell = swipedCell, swipedCell != self.swipeable {
                    return
                }
            }
            
            let translation = gesture.translation(in: target).x
            scrollRatio = 1.0
            
            // Check if dragging past the center of the opposite direction of action view, if so
            // then we need to apply elasticity
            if (translation + originalCenter - swipeable.bounds.midX) * actionsView.orientation.scale > 0 {
                target.center.x = gesture.elasticTranslation(in: target,
                                                             withLimit: .zero,
                                                             fromOriginalCenter: CGPoint(x: originalCenter, y: 0),
                                                             swipeToScrollRatio: (actionsView.options.expansionStyle?.swipeToScrollRatio) ?? 1).x
                swipeable.actionsView?.visibleWidth = abs((swipeable as Swipeable).frame.minX)
                scrollRatio = elasticScrollRatio
                return
            }
            
            if let expansionStyle = actionsView.options.expansionStyle, let scrollView = scrollView {
                
                let referenceFrame = actionsContainerView != swipeable ? actionsContainerView.frame : nil;
                let expanded = expansionStyle.shouldExpand(view: swipeable, gesture: gesture, in: scrollView, within: referenceFrame)
                let targetOffset = expansionStyle.targetOffset(for: swipeable)
                let currentOffset = abs(translation + originalCenter - swipeable.bounds.midX)
                
                if expanded && !actionsView.expanded && targetOffset > currentOffset {
                    let centerForTranslationToEdge = swipeable.bounds.midX - targetOffset * actionsView.orientation.scale
                    let delta = centerForTranslationToEdge - originalCenter
                    
                    animate(toOffset: centerForTranslationToEdge)
                    gesture.setTranslation(CGPoint(x: delta / expansionStyle.swipeToScrollRatio, y: 0), in: swipeable.superview!)
                } else {
                    target.center.x = gesture.elasticTranslation(in: target,
                                                                 withLimit: CGSize(width: targetOffset, height: 0),
                                                                 fromOriginalCenter: CGPoint(x: originalCenter, y: 0),
                                                                 swipeToScrollRatio: expansionStyle.swipeToScrollRatio,
                                                                 applyingRatio: expansionStyle.targetOverscrollElasticity).x
                    swipeable.actionsView?.visibleWidth = abs(actionsContainerView.frame.minX)
                }
                
                actionsView.setExpanded(expanded: expanded, feedback: true)
            } else {
                target.center.x = gesture.elasticTranslation(in: target,
                                                             withLimit: CGSize(width: actionsView.preferredWidth, height: 0),
                                                             fromOriginalCenter: CGPoint(x: originalCenter, y: 0),
                                                             swipeToScrollRatio: 1,
                                                             applyingRatio: elasticScrollRatio).x
                swipeable.actionsView?.visibleWidth = abs(actionsContainerView.frame.minX)
                
                if (target.center.x - originalCenter) / translation != 1.0 {
                    scrollRatio = elasticScrollRatio
                }
            }
        case .ended, .cancelled, .failed:
            guard let actionsView = swipeable.actionsView, let actionsContainerView = self.actionsContainerView else { return }
            if swipeable.state.isActive == false && swipeable.bounds.midX == target.center.x  {
                return
            }
            
            swipeable.state = targetState(forVelocity: velocity)

            // If customActionTrigger is true, then perform the last action immediately (without showing the menu)
            // If it's false, fall back to previous behavior
            let shouldOverridePerformAction: Bool
            if let customActionTrigger = self.customActionTrigger {
                switch swipeable.state {
                // Check left and right separately to ensure that the user is flicking in the right direction
                case .left:
                    shouldOverridePerformAction = velocity.x > 0 && customActionTrigger(gesture)
                case .right:
                    shouldOverridePerformAction = velocity.x < 0 && customActionTrigger(gesture)
                default:
                    shouldOverridePerformAction = false
                }
            } else {
                // The feature is disabled
                shouldOverridePerformAction = false
            }

            let shouldForceCloseMenu: Bool
            if let forceMenuCloseTrigger = self.forceMenuCloseTrigger {
                switch swipeable.state {
                case .left:
                    // Only call forceMenuCloseTrigger if the user is swiping in that direction (as if to close the swipe cell)
                    shouldForceCloseMenu = velocity.x < 0 && forceMenuCloseTrigger(gesture)
                case .right:
                    shouldForceCloseMenu = velocity.x > 0 && forceMenuCloseTrigger(gesture)
                default:
                    shouldForceCloseMenu = false
                }
            } else {
                shouldForceCloseMenu = false
            }

            let containsOnlyOneAction = actionsView.actions.count == 1
            let performAction = actionsView.expanded == true || shouldOverridePerformAction
            
            if shouldForceCloseMenu || (containsOnlyOneAction && !performAction) {
                // Set active to false and animate back to the start position
                let targetOffset = targetCenter(active: false)
                let distance = targetOffset - actionsView.center.x
                let normalizedVelocity = velocity.x * scrollRatio / distance

                animate(toOffset: targetOffset, withInitialVelocity: normalizedVelocity) { _ in
                    if swipeable.state == .center {
                        self.reset()
                    }
                }
            } else if performAction, let expandedAction = actionsView.expandableAction  {
                // Give haptic feedback in this case since we skipped the expanded state
                if shouldOverridePerformAction {
                    actionsView.feedbackGenerator.impactOccurred()
                    actionsView.feedbackGenerator.prepare()
                }

                perform(action: expandedAction)
            } else {
                let targetOffset = targetCenter(active: swipeable.state.isActive)
                let distance = targetOffset - actionsContainerView.center.x
                let normalizedVelocity = velocity.x * scrollRatio / distance
                
                animate(toOffset: targetOffset, withInitialVelocity: normalizedVelocity) { _ in
                    if self.swipeable?.state == .center {
                        self.reset()
                    }
                }
                
                if !swipeable.state.isActive {
                    delegate?.swipeController(self, didEndEditingSwipeableFor: actionsView.orientation)
                }
            }
        default: break
        }
    }
    
    @discardableResult
    func showActionsView(for orientation: SwipeActionsOrientation) -> Bool {
        guard let actions = delegate?.swipeController(self, editActionsForSwipeableFor: orientation), actions.count > 0 else { return false }
        guard let swipeable = self.swipeable else { return false }
        
        originalLayoutMargins = swipeable.layoutMargins
        
        configureActionsView(with: actions, for: orientation)
        
        delegate?.swipeController(self, willBeginEditingSwipeableFor: orientation)
        
        return true
    }
    
    func configureActionsView(with actions: [SwipeAction], for orientation: SwipeActionsOrientation) {
        guard var swipeable = self.swipeable,
            let actionsContainerView = self.actionsContainerView,
            let scrollView = self.scrollView else {
                return
        }

        let options = delegate?.swipeController(self, editActionsOptionsForSwipeableFor: orientation) ?? SwipeOptions()
        
        swipeable.actionsView?.removeFromSuperview()
        swipeable.actionsView = nil
        
        var contentEdgeInsets = UIEdgeInsets.zero
        if let visibleTableViewRect = delegate?.swipeController(self, visibleRectFor: scrollView) {
            
            let frame = (swipeable as Swipeable).frame
            let visibleSwipeableRect = frame.intersection(visibleTableViewRect)
            if visibleSwipeableRect.isNull == false {
                let top = visibleSwipeableRect.minY > frame.minY ? max(0, visibleSwipeableRect.minY - frame.minY) : 0
                let bottom = max(0, frame.size.height - visibleSwipeableRect.size.height - top)
                contentEdgeInsets = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
            }
        }
        
        let actionsView = SwipeActionsView(contentEdgeInsets: contentEdgeInsets,
                                           maxSize: swipeable.bounds.size,
                                           safeAreaInsetView: scrollView,
                                           options: options,
                                           orientation: orientation,
                                           actions: actions)
        actionsView.delegate = self
        
        actionsContainerView.addSubview(actionsView)
        
        actionsView.heightAnchor.constraint(equalTo: swipeable.heightAnchor).isActive = true
        actionsView.widthAnchor.constraint(equalTo: swipeable.widthAnchor, multiplier: 2).isActive = true
        actionsView.topAnchor.constraint(equalTo: swipeable.topAnchor).isActive = true
        
        if orientation == .left {
            actionsView.rightAnchor.constraint(equalTo: actionsContainerView.leftAnchor).isActive = true
        } else {
            actionsView.leftAnchor.constraint(equalTo: actionsContainerView.rightAnchor).isActive = true
        }
        
        actionsView.setNeedsUpdateConstraints()
        
        swipeable.actionsView = actionsView
        
        swipeable.state = .dragging
    }
    
    func animate(duration: Double = 0.7, toOffset offset: CGFloat, withInitialVelocity velocity: CGFloat = 0, completion: ((Bool) -> Void)? = nil) {
        stopAnimatorIfNeeded()
        
        swipeable?.layoutIfNeeded()
        
        let animator: SwipeAnimator = {
            if velocity != 0 {
                if #available(iOS 10, *) {
                    let velocity = CGVector(dx: velocity, dy: velocity)
                    let parameters = UISpringTimingParameters(mass: 1.0, stiffness: 100, damping: 18, initialVelocity: velocity)
                    return UIViewPropertyAnimator(duration: 0.0, timingParameters: parameters)
                } else {
                    return UIViewSpringAnimator(duration: duration, damping: 1.0, initialVelocity: velocity)
                }
            } else {
                if #available(iOS 10, *) {
                    return UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0)
                } else {
                    return UIViewSpringAnimator(duration: duration, damping: 1.0)
                }
            }
        }()
        
        animator.addAnimations({
            guard let swipeable = self.swipeable, let actionsContainerView = self.actionsContainerView else { return }
            
            actionsContainerView.center = CGPoint(x: offset, y: actionsContainerView.center.y)
            swipeable.actionsView?.visibleWidth = abs(actionsContainerView.frame.minX)
            swipeable.layoutIfNeeded()
        })
        
        if let completion = completion {
            animator.addCompletion(completion: completion)
        }
        
        self.animator = animator
        
        animator.startAnimation()
    }
    
    func traitCollectionDidChange(from previousTraitCollrection: UITraitCollection?, to traitCollection: UITraitCollection) {
        guard let swipeable = self.swipeable,
            let actionsContainerView = self.actionsContainerView,
            previousTraitCollrection != nil else {
                return
        }
        
        if swipeable.state == .left || swipeable.state == .right {
            let targetOffset = targetCenter(active: swipeable.state.isActive)
            actionsContainerView.center = CGPoint(x: targetOffset, y: actionsContainerView.center.y)
            swipeable.actionsView?.visibleWidth = abs(actionsContainerView.frame.minX)
            swipeable.layoutIfNeeded()
        }        
    }
    
    func stopAnimatorIfNeeded() {
        if animator?.isRunning == true {
            animator?.stopAnimation(true)
        }
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        hideSwipe(animated: true)
    }
    
    @objc func handleTablePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            hideSwipe(animated: true)
        }
    }
    
    func targetState(forVelocity velocity: CGPoint) -> SwipeState {
        guard let actionsView = swipeable?.actionsView else { return .center }
        
        switch actionsView.orientation {
        case .left:
            return (velocity.x < 0 && !actionsView.expanded) ? .center : .left
        case .right:
            return (velocity.x > 0 && !actionsView.expanded) ? .center : .right
        }
    }
    
    func targetCenter(active: Bool) -> CGFloat {
        guard let swipeable = self.swipeable else { return 0 }
        guard let actionsView = swipeable.actionsView, active == true else { return swipeable.bounds.midX }
        
        return swipeable.bounds.midX - actionsView.preferredWidth * actionsView.orientation.scale
    }
    
    func configure() {
        swipeable?.addGestureRecognizer(tapGestureRecognizer)
        swipeable?.addGestureRecognizer(panGestureRecognizer)
    }
    
    func reset() {
        swipeable?.state = .center
        
        swipeable?.actionsView?.removeFromSuperview()
        swipeable?.actionsView = nil
    }
    
}

extension SwipeController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGestureRecognizer {
            if UIAccessibility.isVoiceOverRunning {
                scrollView?.hideSwipeables()
            }
            
            let swipedCell = scrollView?.swipeables.first(where: {
                $0.state.isActive ||
                    $0.panGestureRecognizer.state == .began ||
                    $0.panGestureRecognizer.state == .changed ||
                    $0.panGestureRecognizer.state == .ended
            })
            return swipedCell == nil ? false : true
        }
        
        if gestureRecognizer == panGestureRecognizer,
            let view = gestureRecognizer.view,
            let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = gestureRecognizer.translation(in: view)
            return abs(translation.y) <= abs(translation.x)
        }
        
        return true
    }
}

extension SwipeController: SwipeActionsViewDelegate {
    func swipeActionsView(_ swipeActionsView: SwipeActionsView, didSelect action: SwipeAction) {
        perform(action: action)
    }
    
    func perform(action: SwipeAction) {
        guard let actionsView = swipeable?.actionsView else { return }
        
        if action == actionsView.expandableAction, let expansionStyle = actionsView.options.expansionStyle {
            // Trigger the expansion (may already be expanded from drag)
            actionsView.setExpanded(expanded: true)
            
            switch expansionStyle.completionAnimation {
            case .bounce:
                perform(action: action, hide: true)
            case .fill(let fillOption):
                performFillAction(action: action, fillOption: fillOption)
            }
        } else {
            perform(action: action, hide: action.hidesWhenSelected)
        }
    }
    
    func perform(action: SwipeAction, hide: Bool) {
        guard let indexPath = swipeable?.indexPath else { return }

        if hide {
            hideSwipe(animated: true)
        }

        action.handler?(action, indexPath)
    }
    
    func performFillAction(action: SwipeAction, fillOption: SwipeExpansionStyle.FillOptions) {
        guard let swipeable = self.swipeable, let actionsContainerView = self.actionsContainerView else { return }
        guard let actionsView = swipeable.actionsView, let indexPath = swipeable.indexPath else { return }

        let newCenter = swipeable.bounds.midX - (swipeable.bounds.width + actionsView.minimumButtonWidth) * actionsView.orientation.scale
        
        action.completionHandler = { [weak self] style in
            guard let `self` = self else { return }
            action.completionHandler = nil
            
            self.delegate?.swipeController(self, didEndEditingSwipeableFor: actionsView.orientation)
            
            switch style {
            case .delete:
                actionsContainerView.mask = actionsView.createDeletionMask()
                
                self.delegate?.swipeController(self, didDeleteSwipeableAt: indexPath)
                
                UIView.animate(withDuration: 0.3, animations: {
                    guard let actionsContainerView = self.actionsContainerView else { return }
                    
                    actionsContainerView.center.x = newCenter
                    actionsContainerView.mask?.frame.size.height = 0
                    swipeable.actionsView?.visibleWidth = abs(actionsContainerView.frame.minX)
                    
                    if fillOption.timing == .after {
                        actionsView.alpha = 0
                    }
                }) { [weak self] _ in
                    self?.actionsContainerView?.mask = nil
                    self?.reset()
                }
            case .reset:
                self.hideSwipe(animated: true)
            }
        }
        
        let invokeAction = {
            action.handler?(action, indexPath)
            
            if let style = fillOption.autoFulFillmentStyle {
                action.fulfill(with: style)
            }
        }
        
        animate(duration: 0.3, toOffset: newCenter) { _ in
            if fillOption.timing == .after {
                invokeAction()
            }
        }
        
        if fillOption.timing == .with {
            invokeAction()
        }
    }
    
    func hideSwipe(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard var swipeable = self.swipeable, let actionsContainerView = self.actionsContainerView else { return }
        guard swipeable.state == .left || swipeable.state == .right else { return }
        guard let actionView = swipeable.actionsView else { return }
        
        swipeable.state = .animatingToCenter
        
        let targetCenter = self.targetCenter(active: false)
        
        if animated {
            animate(toOffset: targetCenter) { complete in
                self.reset()
                completion?(complete)
            }
        } else {
            actionsContainerView.center = CGPoint(x: targetCenter, y: actionsContainerView.center.y)
            swipeable.actionsView?.visibleWidth = abs(actionsContainerView.frame.minX)
            reset()
        }
        
        delegate?.swipeController(self, didEndEditingSwipeableFor: actionView.orientation)
    }
    
    func showSwipe(orientation: SwipeActionsOrientation, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        setSwipeOffset(.greatestFiniteMagnitude * orientation.scale * -1,
                       animated: animated,
                       completion: completion)
    }
    
    func setSwipeOffset(_ offset: CGFloat, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard var swipeable = self.swipeable, let actionsContainerView = self.actionsContainerView else { return }
        
        guard offset != 0 else {
            hideSwipe(animated: animated, completion: completion)
            return
        }
        
        let orientation: SwipeActionsOrientation = offset > 0 ? .left : .right
        let targetState = SwipeState(orientation: orientation)
        
        if swipeable.state != targetState {
            guard showActionsView(for: orientation) else { return }
            
            scrollView?.hideSwipeables()
            
            swipeable.state = targetState
        }
        
        let maxOffset = min(swipeable.bounds.width, abs(offset)) * orientation.scale * -1
        let targetCenter = abs(offset) == CGFloat.greatestFiniteMagnitude ? self.targetCenter(active: true) : swipeable.bounds.midX + maxOffset
        
        if animated {
            animate(toOffset: targetCenter) { complete in
                completion?(complete)
            }
        } else {
            actionsContainerView.center.x = targetCenter
            swipeable.actionsView?.visibleWidth = abs(actionsContainerView.frame.minX)
        }
    }
}
