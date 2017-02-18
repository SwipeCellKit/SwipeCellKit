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
    
    var expansionAnimator: UIViewPropertyAnimator?

    let orientation: SwipeActionsOrientation
    let actions: [SwipeAction]
    let options: SwipeTableOptions
    
    var minimumButtonWidth: CGFloat = 74

    var visibleWidth: CGFloat = 0 {
        didSet {
            if options.transitionStyle == .reveal {
                bounds.origin.x = (preferredWidth - visibleWidth) * orientation.scale
            } else if options.transitionStyle == .drag {
                bounds.origin.x = (contentSize.width - visibleWidth) * orientation.scale                
            }
            
            setNeedsLayout()
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

            if expansionAnimator?.isRunning == true {
                expansionAnimator?.stopAnimation(true)
            }
            
            expansionAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1.0) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            
            expansionAnimator?.startAnimation()
        }
    }
    
    var expandableAction: SwipeAction? {
        return options.expansionStyle != .none ? actions.last : nil
    }
    
    init(maxSize: CGSize, options: SwipeTableOptions, orientation: SwipeActionsOrientation, actions: [SwipeAction]) {
        self.options = options
        self.orientation = orientation
        self.actions = actions.reversed()
        
        super.init(frame: .zero)
        
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = options.backgroundColor ?? #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        
        addButtons(for: self.actions, withMaximum: maxSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addButtons(for actions: [SwipeAction], withMaximum size: CGSize) {
        subviews.forEach { $0.removeFromSuperview() }
        
        for action in actions {
            let actionButton = SwipeActionButton(frame: CGRect(origin: .zero, size: CGSize(width: size.width * 2, height: size.height)),
                                                 action: action)
            addSubview(actionButton)
            
            actionButton.addTarget(self, action: #selector(actionTapped(button:)), for: .touchUpInside)
            
            minimumButtonWidth = max(minimumButtonWidth, actionButton.preferredWidth)
        }
    }
    
    func actionTapped(button: SwipeActionButton) {
        guard let index = subviews.index(of: button) else { return }

        delegate?.swipeActionsView(self, didSelect: actions[index])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for subview in subviews.enumerated() {
            switch options.transitionStyle {
            case .border:
                let diff = visibleWidth - contentSize.width
                subview.element.frame.origin.x = (CGFloat(subview.offset) * contentSize.width / CGFloat(actions.count) + diff) * orientation.scale
            case .reveal, .drag:
                subview.element.frame.origin.x = (CGFloat(subview.offset) * minimumButtonWidth) * orientation.scale
            }
        }
        
        if expanded {
            subviews.last?.frame.origin.x = 0 + bounds.origin.x
        }
    }
}
