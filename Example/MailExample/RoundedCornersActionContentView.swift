//
//  RoundedCornersActionContentView.swift
//  MailExample
//
//  Created by Ilia Sedov on 05.05.2022.
//

import UIKit
import SwipeCellKit

class RoundedCornersActionContentView: ActionContentView {
    private let bgView = UIView()
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private var action: SwipeAction?
    private var highlightedBackgroundColor: UIColor?
    private var highlightedTextColor: UIColor?

    override func setupView(with action: SwipeAction) {
        self.action = action
        highlightedBackgroundColor = action.highlightedBackgroundColor ?? action.backgroundColor?.getHighlightedColor()
        highlightedTextColor = action.highlightedTextColor ?? .white.getHighlightedColor()

        buildView()

        bgView.backgroundColor = action.backgroundColor
        titleLabel.font = action.font ?? UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        titleLabel.textColor = action.textColor ?? .white
        titleLabel.text = action.title
        imageView.image = action.image
    }

    private func buildView() {
        bgView.layer.cornerRadius = 12.0
        bgView.layer.cornerCurve = .continuous
        addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false


        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.numberOfLines = 1
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

        imageView.tintColor = .white

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.distribution = .equalCentering
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),

            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    override func preferredWidth(maximum: CGFloat) -> CGFloat {
        let width = maximum > 0 ? maximum : CGFloat.greatestFiniteMagnitude
        let textWidth = titleBoundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).width
        let imageWidth = imageView.image?.size.width ?? 0

        let leftInset: CGFloat = 4
        let rightInset: CGFloat = 4

        return min(width, max(textWidth, imageWidth) + leftInset + rightInset)
    }

    private func titleBoundingRect(with size: CGSize) -> CGRect {
        guard let title = titleLabel.text else { return .zero }

        return title.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin],
            attributes: [NSAttributedString.Key.font: titleLabel.font as Any],
            context: nil
        ).integral
    }

    override var isHighlighted: Bool {
        didSet {
            guard let action = action else { return }

            if isHighlighted {
                bgView.backgroundColor = highlightedBackgroundColor
                titleLabel.textColor = highlightedTextColor
            } else {
                bgView.backgroundColor = action.backgroundColor
                titleLabel.textColor = action.textColor ?? .white
            }
        }
    }
}
