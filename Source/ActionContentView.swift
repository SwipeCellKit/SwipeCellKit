//
//  ActionContentView.swift
//  SwipeCellKit
//
//  Created by Ilia Sedov on 05.05.2022.
//

import UIKit

open class ActionContentView: UIView {
    public init(action: SwipeAction) {
        super.init(frame: .zero)
        setupView(with: action)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func preferredWidth(maximum: CGFloat) -> CGFloat {
        0.0
    }

    open func setupView(with action: SwipeAction) {

    }

    open var isHighlighted: Bool = false
}
