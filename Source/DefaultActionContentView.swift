//
//  DefaultActionContentView.swift
//  SwipeCellKit
//
//  Created by Ilia Sedov on 05.05.2022.
//

import UIKit

class DefaultActionContentView: ActionContentView {
    var spacing: CGFloat = 8
    var maximumImageHeight: CGFloat = 0
    private let innerButton = InnerButtonContentView(frame: .zero)
    private var highlightedBackgroundColor: UIColor?
    private var normalBackgroundColor: UIColor?
    private var verticalAlignment: SwipeVerticalAlignment = .centerFirstBaseline

    override func setupView(with action: SwipeAction) {
        normalBackgroundColor = action.backgroundColor
        backgroundColor = action.backgroundColor
        innerButton.contentHorizontalAlignment = .center

        tintColor = action.textColor ?? .white
        let highlightedTextColor = action.highlightedTextColor ?? tintColor
        highlightedBackgroundColor = action.highlightedBackgroundColor ?? UIColor.black.withAlphaComponent(0.1)

        innerButton.titleLabel?.font = action.font ?? UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        innerButton.titleLabel?.textAlignment = .center
        innerButton.titleLabel?.lineBreakMode = .byWordWrapping
        innerButton.titleLabel?.numberOfLines = 0

        accessibilityLabel = action.accessibilityLabel

        innerButton.setTitle(action.title, for: .normal)
        innerButton.setTitleColor(tintColor, for: .normal)
        innerButton.setTitleColor(highlightedTextColor, for: .highlighted)
        innerButton.setImage(action.image, for: .normal)
        innerButton.setImage(action.highlightedImage ?? action.image, for: .highlighted)

        addSubview(innerButton)
        innerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            innerButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            innerButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            innerButton.topAnchor.constraint(equalTo: topAnchor),
            innerButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        innerButton.isUserInteractionEnabled = false
    }

    override var isHighlighted: Bool {
        didSet {
            innerButton.isHighlighted = isHighlighted
            backgroundColor = isHighlighted ? highlightedBackgroundColor : normalBackgroundColor
        }
    }

    override func preferredWidth(maximum: CGFloat) -> CGFloat {
        let width = maximum > 0 ? maximum : CGFloat.greatestFiniteMagnitude
        let textWidth = innerButton.titleBoundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).width
        let imageWidth = innerButton.currentImage?.size.width ?? 0
        let contentWidth = max(textWidth, imageWidth) + innerButton.contentEdgeInsets.left + innerButton.contentEdgeInsets.right

        return min(width, contentWidth)
    }
}

private class InnerButtonContentView: UIButton {
    var maximumImageHeight: CGFloat = 24
    var spacing: CGFloat = 10
    var verticalAlignment: SwipeVerticalAlignment = .centerFirstBaseline

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = contentRect.center(size: titleBoundingRect(with: contentRect.size).size)
        rect.origin.y = alignmentRect.minY + imageHeight + currentSpacing
        return rect.integral
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: contentEdgeInsets.top + alignmentRect.height + contentEdgeInsets.bottom
        )
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = contentRect.center(size: currentImage?.size ?? .zero)
        rect.origin.y = alignmentRect.minY + (imageHeight - rect.height) / 2
        return rect
    }

    func titleBoundingRect(with size: CGSize) -> CGRect {
        guard let title = currentTitle,
              let font = titleLabel?.font else { return .zero }

        return title.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        ).integral
    }

    var alignmentRect: CGRect {
        let contentRect = contentRect(forBounds: bounds)
        let titleHeight = titleBoundingRect(
            with: verticalAlignment == .centerFirstBaseline ? CGRect.infinite.size : contentRect.size
        ).integral.height
        let totalHeight = imageHeight + titleHeight + currentSpacing

        return contentRect.center(size: CGSize(width: contentRect.width, height: totalHeight))
    }

    private var imageHeight: CGFloat {
        currentImage == nil ? 0 : maximumImageHeight
    }

    private var currentSpacing: CGFloat {
        (currentTitle?.isEmpty == false && imageHeight > 0) ? spacing : 0
    }
}

private extension CGRect {
    func center(size: CGSize) -> CGRect {
        let dx = width - size.width
        let dy = height - size.height
        return CGRect(x: origin.x + dx * 0.5, y: origin.y + dy * 0.5, width: size.width, height: size.height)
    }
}
