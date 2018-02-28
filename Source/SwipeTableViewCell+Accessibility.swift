//
//  SwipeTableViewCell+Accessibility.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

extension SwipeTableViewCell {
    /// :nodoc:
    open override func accessibilityElementCount() -> Int {
        guard state != .center else {
            return super.accessibilityElementCount()
        }

        return 1
    }
    
    /// :nodoc:
    open override func accessibilityElement(at index: Int) -> Any? {
        guard state != .center else {
            return super.accessibilityElement(at: index)
        }

        return actionsView
    }
    
    /// :nodoc:
    open override func index(ofAccessibilityElement element: Any) -> Int {
        guard state != .center else {
            return super.index(ofAccessibilityElement: element)
        }

        return element is SwipeActionsView ? 0 : NSNotFound
    }
}

extension SwipeTableViewCell {
    /// :nodoc:
    open override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            guard let tableView = tableView, let indexPath = tableView.indexPath(for: self) else {
                return super.accessibilityCustomActions
            }
            
            let leftActions = delegate?.tableView(tableView, editActionsForRowAt: indexPath, for: .left) ?? []
            let rightActions = delegate?.tableView(tableView, editActionsForRowAt: indexPath, for: .right) ?? []
            
            let actions = [rightActions.first, leftActions.first].flatMap({ $0 }) + rightActions.dropFirst() + leftActions.dropFirst()
            
            if actions.count > 0 {
                return actions.map({ SwipeAccessibilityCustomAction(action: $0,
                                                                    indexPath: indexPath,
                                                                    target: self,
                                                                    selector: #selector(performAccessibilityCustomAction(accessibilityCustomAction:))) })
            } else {
                return super.accessibilityCustomActions
            }
        }
        
        set {
            super.accessibilityCustomActions = newValue
        }
    }
    
    @objc func performAccessibilityCustomAction(accessibilityCustomAction: SwipeAccessibilityCustomAction) -> Bool {
        guard let tableView = tableView else { return false }
        
        let swipeAction = accessibilityCustomAction.action
        
        swipeAction.handler?(swipeAction, accessibilityCustomAction.indexPath)
        
        if swipeAction.style == .destructive {
            tableView.deleteRows(at: [accessibilityCustomAction.indexPath], with: .fade)
        }
        
        return true
    }
}

class SwipeAccessibilityCustomAction: UIAccessibilityCustomAction {
    let action: SwipeAction
    let indexPath: IndexPath
    
    init(action: SwipeAction, indexPath: IndexPath, target: Any, selector: Selector) {
        
        self.action = action
        self.indexPath = indexPath
        
        let name = action.accessibilityLabel ?? action.title ?? action.image?.accessibilityIdentifier ?? ""
        
        super.init(name: name, target: target, selector: selector)
    }
}
