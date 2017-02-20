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
    enum SwipeState: Int {
        case center = 0
        case left
        case right
        case animatingToCenter
    }
    
    /// The object that acts as the delegate of the `SwipeTableViewCell`.
    public weak var delegate: SwipeTableViewCellDelegate?

    var feedbackGenerator: UIImpactFeedbackGenerator?
    var animator: UIViewPropertyAnimator?

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
    
    let elasticScrollRation: CGFloat = 0.4
    var scrollRatio: CGFloat = 1.0
    
    /// :nodoc:
    override open var center: CGPoint {
        didSet {
            actionsView?.visibleWidth = abs(frame.minX)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow == nil {
            reset()
        }
    }
    
    /// :nodoc:
    override open func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            hideSwipe(animated: false)
        }
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        guard isEditing == false else { return }
        guard let target = gesture.view else { return }
        
        switch gesture.state {
        case .began:
            originalCenter = center.x
            
            feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator?.prepare()

            if state == .center || state == .animatingToCenter {
                stopAnimatorIfNeeded()
            
                let velocity = gesture.velocity(in: target)
                let orientation: SwipeActionsOrientation = velocity.x > 0 ? .left : .right

                handleBeginPanIfNecessary(for: orientation)
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
                scrollRatio = elasticScrollRation
                return
            }
            
            let expanded: Bool
            switch actionsView.options.expansionStyle {
            case .selection:
                target.center.x = gesture.elasticTranslation(in: target,
                                                             withLimit: CGSize(width: bounds.width / 2, height: 0),
                                                             fromOriginalCenter: CGPoint(x: originalCenter, y: 0)).x
                expanded = abs(frame.minX) >= bounds.midX
            case .destructive:
                let distance = abs(translation)
                let location = gesture.location(in: superview!).x
                expanded = (actionsView.orientation == .right ? location < 80 : location > bounds.width - 80) && (state != .center || distance > actionsView.preferredWidth)
                
                let limit: CGFloat = bounds.width - 30
                if expanded && !actionsView.expanded {
                    let centerForTranslationToEdge = bounds.midX - limit * actionsView.orientation.scale
                    let delta = centerForTranslationToEdge - originalCenter
                    
                    animate(toOffset: centerForTranslationToEdge)
                    gesture.setTranslation(CGPoint(x: delta, y: 0), in: superview!)
                } else {
                    target.center.x = gesture.elasticTranslation(in: target,
                                                                 withLimit: CGSize(width: limit, height: 0),
                                                                 fromOriginalCenter: CGPoint(x: originalCenter, y: 0)).x
                }
                break
            default:
                target.center.x = gesture.elasticTranslation(in: target,
                                                             withLimit: CGSize(width: actionsView.preferredWidth, height: 0),
                                                             fromOriginalCenter: CGPoint(x: originalCenter, y: 0),
                                                             applyingRatio: elasticScrollRation).x
                if (target.center.x - originalCenter) / translation != 1.0 {
                    scrollRatio = elasticScrollRation
                }
                
                expanded = false
                break
            }
            
            if expanded != actionsView.expanded {
                feedbackGenerator?.impactOccurred()
                feedbackGenerator?.prepare()
            }
            
            actionsView.expanded = expanded
            
        case .ended:
            guard let actionsView = actionsView else { return }

            let velocity = gesture.velocity(in: target)
            state = targetState(forVelocity: velocity)
            
            feedbackGenerator = nil

            if actionsView.expanded == true, let expandedAction = actionsView.expandableAction  {
                perform(action: expandedAction)
            } else {
                let targetOffset = state != .center ? targetCenter(active: true) : bounds.midX
                let distance = targetOffset - center.x
                let normalizedVelocity = velocity.x * scrollRatio / distance
                
                animate(toOffset: targetOffset, withInitialVelocity: normalizedVelocity) { _ in
                    if self.state == .center {
                        self.reset()
                    }
                }
            }

        default: break
        }
    }
    
    func handleBeginPanIfNecessary(for orientation: SwipeActionsOrientation) {
        guard let tableView = tableView,
            let indexPath = tableView.indexPath(for: self),
            let actions = delegate?.tableView(tableView, editActionsForRowAt: indexPath, for: orientation),
            actions.count > 0
            else {
                return
        }
        
        originalLayoutMargins = super.layoutMargins
        
        // Remove highlight and deselect any selected cells
        isHighlighted = false
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        selectedIndexPaths?.forEach { tableView.deselectRow(at: $0, animated: false) }
        
        // Temporarily remove table gestures
        tableView.setGestureEnabled(false)
        
        configureActionView(with: actions, for: orientation)
    }
    
    func configureActionView(with actions: [SwipeAction], for orientation: SwipeActionsOrientation) {
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
        
        self.actionsView = actionsView
    }
    
    func animate(toOffset offset: CGFloat, withInitialVelocity velocity: CGFloat = 0, completion: ((UIViewAnimatingPosition) -> Void)? = nil) {
        stopAnimatorIfNeeded()
        
        layoutIfNeeded()
        
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
            self.center = CGPoint(x: offset, y: self.center.y)
            
            self.layoutIfNeeded()
        })
        
        if let completion = completion {
            animator.addCompletion(completion)
        }
        
        self.animator = animator

        animator.startAnimation()
    }
    
    func stopAnimatorIfNeeded() {
        if animator?.isRunning == true {
            animator?.stopAnimation(true)
        }
    }

    func handleTap(gesture: UITapGestureRecognizer) {
        hideSwipe(animated: true)
    }
    
    func handleTablePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            hideSwipe(animated: true)
        }
    }
    
    // Override so we can accept touches anywhere within the cell's minY/maxY.
    // This is required to detect touches on the `SwipeActionsView` sitting alongside the
    // `SwipeTableCell`.
    /// :nodoc:
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let point = convert(point, to: superview!)

        for cell in tableView?.swipeCells ?? [] {
            if (cell.state == .left || cell.state == .right) && !cell.contains(point: point) {
                tableView?.hideSwipeCell()
                return false
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
        
        tableView?.setGestureEnabled(true)
        
        actionsView?.removeFromSuperview()
        actionsView = nil
    }
    
    /**
     Hides the swipe actions and returns the cell to center.
     
     - parameter animated: Specify `true` to animate the hiding of the swipe actions or `false` to hide it immediately.
     */
    public func hideSwipe(animated: Bool) {
        guard state == .left || state == .right else { return }

        state = .animatingToCenter
        
        tableView?.setGestureEnabled(true)

        let targetCenter = self.targetCenter(active: false)
        
        if animated {
            animate(toOffset: targetCenter) { _ in
                self.reset()
            }
        } else {
            center = CGPoint(x: targetCenter, y: self.center.y)
            reset()
        }
    }
}

extension SwipeTableViewCell: SwipeActionsViewDelegate {
    func swipeActionsView(_ swipeActionsView: SwipeActionsView, didSelect action: SwipeAction) {
        perform(action: action)
    }
    
    func perform(action: SwipeAction) {
        guard let actionsView = actionsView,
            let tableView = tableView,
            let indexPath = tableView.indexPath(for: self) else { return }
        
        if actionsView.options.expansionStyle == .destructive && action == actionsView.expandableAction {
            // Trigger the expansion (may already be expanded from drag)
            actionsView.expanded = true
            
            action.handler?(action, indexPath)
            tableView.deleteRows(at: [indexPath], with: .none)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.center.x = self.bounds.midX - (self.bounds.width + 100) * actionsView.orientation.scale
            }) { _ in
                self.reset()
            }
        } else {
            if actionsView.options.expansionStyle == .selection || action.hidesWhenSelected {
                hideSwipe(animated: true)
            }

            action.handler?(action, indexPath)
        }
    }    
}

extension SwipeTableViewCell {
    /// :nodoc:
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGestureRecognizer {
            if let cells = tableView?.visibleCells as? [SwipeTableViewCell] {
                let cell = cells.first(where: { $0.state != .center })
                return cell == nil ? false : true
            }
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
