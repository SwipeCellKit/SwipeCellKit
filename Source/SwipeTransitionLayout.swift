//
//  SwipeTransitionLayout.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

// MARK: - Layout Protocol

protocol SwipeTransitionLayout {
    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext)
    func layout(view: UIView, atIndex index: Int, with context: ActionsViewLayoutContext)
    func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat]
}

// MARK: - Layout Context 

struct ActionsViewLayoutContext {
    let numberOfActions: Int
    let orientation: SwipeActionsOrientation
    let contentSize: CGSize
    let visibleWidth: CGFloat
    let minimumButtonWidth: CGFloat
    
    init(numberOfActions: Int, orientation: SwipeActionsOrientation, contentSize: CGSize = .zero, visibleWidth: CGFloat = 0, minimumButtonWidth: CGFloat = 0) {
        self.numberOfActions = numberOfActions
        self.orientation = orientation
        self.contentSize = contentSize
        self.visibleWidth = visibleWidth
        self.minimumButtonWidth = minimumButtonWidth
    }
    
    static func newContext(for actionsView: SwipeActionsView) -> ActionsViewLayoutContext {
        return ActionsViewLayoutContext(numberOfActions: actionsView.actions.count,
                                        orientation: actionsView.orientation,
                                        contentSize: actionsView.contentSize,
                                        visibleWidth: actionsView.visibleWidth,
                                        minimumButtonWidth: actionsView.minimumButtonWidth)
    }
}

// MARK: - Supported Layout Implementations 

class BorderTransitionLayout: SwipeTransitionLayout {
    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext) {
    }
    
    func layout(view: UIView, atIndex index: Int, with context: ActionsViewLayoutContext) {
        let diff = context.visibleWidth - context.contentSize.width
        view.frame.origin.x = (CGFloat(index) * context.contentSize.width / CGFloat(context.numberOfActions) + diff) * context.orientation.scale
    }
    
    func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
        let diff = context.visibleWidth - context.contentSize.width
        let visibleWidth = context.contentSize.width / CGFloat(context.numberOfActions) + diff

        // visible widths are all the same regardless of the action view position
        return (0..<context.numberOfActions).map({ _ in visibleWidth })
    }
}

class DragTransitionLayout: SwipeTransitionLayout {
    func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext) {
        view.bounds.origin.x = (context.contentSize.width - context.visibleWidth) * context.orientation.scale
    }
    
    func layout(view: UIView, atIndex index: Int, with context: ActionsViewLayoutContext) {
        view.frame.origin.x = (CGFloat(index) * context.minimumButtonWidth) * context.orientation.scale
    }
    
    func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
        return (0..<context.numberOfActions)
            .map({ max(0, min(context.minimumButtonWidth, context.visibleWidth - (CGFloat($0) * context.minimumButtonWidth))) })
    }
}

class RevealTransitionLayout: DragTransitionLayout {
    override func container(view: UIView, didChangeVisibleWidthWithContext context: ActionsViewLayoutContext) {
        let width = context.minimumButtonWidth * CGFloat(context.numberOfActions)
        view.bounds.origin.x = (width - context.visibleWidth) * context.orientation.scale
    }
    
    override func visibleWidthsForViews(with context: ActionsViewLayoutContext) -> [CGFloat] {
        return super.visibleWidthsForViews(with: context).reversed()
    }
}
