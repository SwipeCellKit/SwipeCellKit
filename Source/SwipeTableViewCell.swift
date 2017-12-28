//
//  SwipeTableViewCell.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

/**
 The `SwipeTableViewCell` class extends `UITableViewCell` and provides more flexible options for cell swiping behavior.
 
 
 The default behavior closely matches the stock Mail.app. If you want to customize the transition style (ie. how the action buttons are exposed), or the expansion style (the behavior when the row is swiped passes a defined threshold), you can return the appropriately configured `SwipeTableOptions` via the `SwipeTableViewCellDelegate` delegate.
 */
open class SwipeTableViewCell: UITableViewCell {
    /// The object that acts as the delegate of the `SwipeTableViewCell`.
    public weak var delegate: SwipeTableViewCellDelegate?
    
    var animator: SwipeAnimator?

    var state = SwipeState.center
    var originalCenter: CGFloat = 0
    
    weak var tableView: UITableView?
    var actionsView: SwipeActionsView?

    var originalLayoutMargins: UIEdgeInsets = .zero
    
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    let elasticScrollRatio: CGFloat = 0.4
    var scrollRatio: CGFloat = 1.0
    
    /// :nodoc:
    override open var center: CGPoint {
        didSet {
            actionsView?.visibleWidth = abs(frame.minX)
        }
    }
    
    /// :nodoc:
    open override var frame: CGRect {
        set { super.frame = state.isActive ? CGRect(origin: CGPoint(x: frame.minX, y: newValue.minY), size: newValue.size) : newValue }
        get { return super.frame }
    }
    
    /// :nodoc:
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    deinit {
        tableView?.panGestureRecognizer.removeTarget(self, action: nil)
    }
    
    func configure() {
        clipsToBounds = false
        
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(panGestureRecognizer)
    }
    
    /// :nodoc:
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
    }
    
    /// :nodoc:
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        var view: UIView = self
        while let superview = view.superview {
            view = superview
            
            if let tableView = view as? UITableView {
                self.tableView = tableView
                
                tableView.panGestureRecognizer.removeTarget(self, action: nil)
                tableView.panGestureRecognizer.addTarget(self, action: #selector(handleTablePan(gesture:)))
                return
            }            
        }
    }
    
    /// :nodoc:
    override open func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            hideSwipe(animated: false)
        }
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        guard isEditing == false else { return }
        guard let target = gesture.view else { return }
        
        switch gesture.state {
        case .began:
            stopAnimatorIfNeeded()

            originalCenter = center.x
            
            if state == .center || state == .animatingToCenter {
                let velocity = gesture.velocity(in: target)
                let orientation: SwipeActionsOrientation = velocity.x > 0 ? .left : .right

                showActionsView(for: orientation)
            }
            
        case .changed:
            guard let actionsView = actionsView else { return }

            let translation = gesture.translation(in: target).x
            scrollRatio = 1.0
            
            // Check if dragging past the center of the opposite direction of action view, if so
            // then we need to apply elasticity
            if (translation + originalCenter - bounds.midX) * actionsView.orientation.scale > 0 {
                target.center.x = gesture.elasticTranslation(in: target,
                                                             withLimit: .zero,
                                                             fromOriginalCenter: CGPoint(x: originalCenter, y: 0)).x
                scrollRatio = elasticScrollRatio
                return
            }
            
            if let expansionStyle = actionsView.options.expansionStyle {
                let expanded = expansionStyle.shouldExpand(view: self, gesture: gesture, in: tableView!)
                let targetOffset = expansionStyle.targetOffset(for: self, in: tableView!)
                let currentOffset = abs(translation + originalCenter - bounds.midX)
                
                if expanded && !actionsView.expanded && targetOffset > currentOffset {
                    let centerForTranslationToEdge = bounds.midX - targetOffset * actionsView.orientation.scale
                    let delta = centerForTranslationToEdge - originalCenter
                    
                    animate(toOffset: centerForTranslationToEdge)
                    gesture.setTranslation(CGPoint(x: delta, y: 0), in: superview!)
                } else {
                    target.center.x = gesture.elasticTranslation(in: target,
                                                                 withLimit: CGSize(width: targetOffset, height: 0),
                                                                 fromOriginalCenter: CGPoint(x: originalCenter, y: 0),
                                                                 applyingRatio: expansionStyle.targetOverscrollElasticity).x
                }
                
                actionsView.setExpanded(expanded: expanded, feedback: true)
            } else {
                target.center.x = gesture.elasticTranslation(in: target,
                                                             withLimit: CGSize(width: actionsView.preferredWidth, height: 0),
                                                             fromOriginalCenter: CGPoint(x: originalCenter, y: 0),
                                                             applyingRatio: elasticScrollRatio).x
                if (target.center.x - originalCenter) / translation != 1.0 {
                    scrollRatio = elasticScrollRatio
                }
            }
        case .ended:
            guard let actionsView = actionsView else { return }

            let velocity = gesture.velocity(in: target)
            state = targetState(forVelocity: velocity)
            
            if actionsView.expanded == true, let expandedAction = actionsView.expandableAction  {
                perform(action: expandedAction)
            } else {
                let targetOffset = targetCenter(active: state.isActive)
                let distance = targetOffset - center.x
                let normalizedVelocity = velocity.x * scrollRatio / distance

                animate(toOffset: targetOffset, withInitialVelocity: normalizedVelocity) { _ in
                    if self.state == .center {
                        self.reset()
                    }
                }

                if !state.isActive {
                    notifyEditingStateChange(active: false)
                }
            }

        default: break
        }
    }
    
    @discardableResult
    func showActionsView(for orientation: SwipeActionsOrientation) -> Bool {
        guard let tableView = tableView,
            let indexPath = tableView.indexPath(for: self),
            let actions = delegate?.tableView(tableView, editActionsForRowAt: indexPath, for: orientation),
            actions.count > 0
            else {
                return false
        }
        
        originalLayoutMargins = super.layoutMargins
        
        // Remove highlight and deselect any selected cells
        super.setHighlighted(false, animated: false)
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        selectedIndexPaths?.forEach { tableView.deselectRow(at: $0, animated: false) }
        
        configureActionsView(with: actions, for: orientation)
        
        return true
    }
    
    func configureActionsView(with actions: [SwipeAction], for orientation: SwipeActionsOrientation) {
        guard let tableView = tableView,
            let indexPath = tableView.indexPath(for: self) else { return }
        
        let options = delegate?.tableView(tableView, editActionsOptionsForRowAt: indexPath, for: orientation) ?? SwipeTableOptions()
        
        self.actionsView?.removeFromSuperview()
        self.actionsView = nil
        
        let actionsView = SwipeActionsView(maxSize: bounds.size,
                                           options: options,
                                           orientation: orientation,
                                           actions: actions)
        
        actionsView.delegate = self
        
        addSubview(actionsView)

        actionsView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        actionsView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2).isActive = true
        actionsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        if orientation == .left {
            actionsView.rightAnchor.constraint(equalTo: leftAnchor).isActive = true
        } else {
            actionsView.leftAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
		
		actionsView.setNeedsUpdateConstraints()
		
		self.actionsView = actionsView

        state = .dragging
        
        notifyEditingStateChange(active: true)
    }
    
    func notifyEditingStateChange(active: Bool) {
        guard let actionsView = actionsView,
            let tableView = tableView,
            let indexPath = tableView.indexPath(for: self) else { return }

        if active {
            delegate?.tableView(tableView, willBeginEditingRowAt: indexPath, for: actionsView.orientation)
        } else {
            delegate?.tableView(tableView, didEndEditingRowAt: indexPath, for: actionsView.orientation)
        }
    }
    
    func animate(duration: Double = 0.7, toOffset offset: CGFloat, withInitialVelocity velocity: CGFloat = 0, completion: ((Bool) -> Void)? = nil) {
        stopAnimatorIfNeeded()
        
        layoutIfNeeded()
        
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
            self.center = CGPoint(x: offset, y: self.center.y)
            
            self.layoutIfNeeded()
        })
        
        if let completion = completion {
            animator.addCompletion(completion: completion)
        }
        
        self.animator = animator

        animator.startAnimation()
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
    
    // Override so we can accept touches anywhere within the cell's minY/maxY.
    // This is required to detect touches on the `SwipeActionsView` sitting alongside the
    // `SwipeTableCell`.
    /// :nodoc:
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superview = superview else { return false }
     
        let point = convert(point, to: superview)

        if !UIAccessibilityIsVoiceOverRunning() {
            for cell in tableView?.swipeCells ?? [] {
                if (cell.state == .left || cell.state == .right) && !cell.contains(point: point) {
                    tableView?.hideSwipeCell()
                    return false
                }
            }
        }
        
        return contains(point: point)
    }
    
    func contains(point: CGPoint) -> Bool {
        return point.y > frame.minY && point.y < frame.maxY
    }
    
    /// :nodoc:
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if state == .center {
            super.setHighlighted(highlighted, animated: animated)
        }
    }
    
    /// :nodoc:
    override open var layoutMargins: UIEdgeInsets {
        get {
            return frame.origin.x != 0 ? originalLayoutMargins : super.layoutMargins
        }
        set {
            super.layoutMargins = newValue
        }
    }
}

extension SwipeTableViewCell {
    func targetState(forVelocity velocity: CGPoint) -> SwipeState {
        guard let actionsView = actionsView else { return .center }
        
        switch actionsView.orientation {
        case .left:
            return (velocity.x < 0 && !actionsView.expanded) ? .center : .left
        case .right:
            return (velocity.x > 0 && !actionsView.expanded) ? .center : .right
        }
    }
    
    func targetCenter(active: Bool) -> CGFloat {
        guard let actionsView = actionsView, active == true else { return bounds.midX }

        return bounds.midX - actionsView.preferredWidth * actionsView.orientation.scale
    }

    func reset() {
        state = .center
        clipsToBounds = false
        actionsView?.removeFromSuperview()
        actionsView = nil
    }
}

extension SwipeTableViewCell: SwipeActionsViewDelegate {
    func swipeActionsView(_ swipeActionsView: SwipeActionsView, didSelect action: SwipeAction) {
        perform(action: action)
    }
    
    func perform(action: SwipeAction) {
        guard let actionsView = actionsView else { return }
        
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
        guard let tableView = tableView, let indexPath = tableView.indexPath(for: self) else { return }

        if hide {
            hideSwipe(animated: true)
        }
        
        action.handler?(action, indexPath)
    }
    
    func performFillAction(action: SwipeAction, fillOption: SwipeExpansionStyle.FillOptions) {
        guard let actionsView = actionsView,
            let tableView = tableView,
            let indexPath = tableView.indexPath(for: self) else { return }
        
        let newCenter = bounds.midX - (bounds.width + actionsView.minimumButtonWidth) * actionsView.orientation.scale

        action.completionHandler = { [weak self] style in
            action.completionHandler = nil

            self?.delegate?.tableView(tableView, didEndEditingRowAt: indexPath, for: actionsView.orientation)
            
            switch style {
            case .delete:
                self?.mask = actionsView.createDeletionMask()
                
                tableView.deleteRows(at: [indexPath], with: .none)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self?.center.x = newCenter
                    self?.mask?.frame.size.height = 0
                    
                    if fillOption.timing == .after {
                        actionsView.alpha = 0
                    }
                }) { [weak self] _ in
                    self?.mask = nil
                    self?.reset()
                }
            case .reset:
                self?.hideSwipe(animated: true)
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
}

extension SwipeTableViewCell {
    /// :nodoc:
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGestureRecognizer {
            if UIAccessibilityIsVoiceOverRunning() {
                tableView?.hideSwipeCell()
            }

            let cell = tableView?.swipeCells.first(where: { $0.state.isActive })
            return cell == nil ? false : true
        }
        
        if gestureRecognizer == panGestureRecognizer,
            let view = gestureRecognizer.view,
            let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer
        {
            let translation = gestureRecognizer.translation(in: view)
            return abs(translation.y) <= abs(translation.x)
        }

        return true
    }
}
