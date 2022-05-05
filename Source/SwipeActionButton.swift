//
//  SwipeActionButton.swift
//
//  Created by Jeremy Koch.
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

class SwipeActionButton: UIControl {
    var shouldHighlight = true
    var highlightedBackgroundColor: UIColor?
    var verticalAlignment: SwipeVerticalAlignment = .centerFirstBaseline
    private var contentView: ActionContentView!

    public convenience init(
        action: SwipeAction,
        contentViewBuilder: (SwipeAction) -> ActionContentView
    ) {
        self.init(frame: .zero)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapControl)))

        contentView = contentViewBuilder(action)
        contentView.isUserInteractionEnabled = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc
    private func tapControl() {
        sendActions(for: .touchUpInside)
    }

    override var isHighlighted: Bool {
        didSet {
            contentView.isHighlighted = isHighlighted
        }
    }

    func preferredWidth(maximum: CGFloat) -> CGFloat {
        contentView.preferredWidth(maximum: maximum)
    }
}
