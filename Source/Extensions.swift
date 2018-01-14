//
//  Extensions.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

extension UITableView {
    var swipeCells: [SwipeTableViewCell] {
        return visibleCells.flatMap({ $0 as? SwipeTableViewCell })
    }
    
    func hideSwipeCell() {
        swipeCells.forEach { $0.hideSwipe(animated: true) }
    }
}

extension UICollectionView {
  var swipeCells: [SwipeCollectionViewCell] {
    return visibleCells as? [SwipeCollectionViewCell] ?? []
  }
  
  func hideSwipeCell() {
    swipeCells.forEach { $0.hideSwipe(animated: true) }
  }
  
  func setGestureEnabled(_ enabled: Bool) {
    gestureRecognizers?.forEach {
      guard $0 != panGestureRecognizer else { return }
      
      $0.isEnabled = enabled
    }
  }
}

extension UIPanGestureRecognizer {
    func elasticTranslation(in view: UIView?, withLimit limit: CGSize, fromOriginalCenter center: CGPoint, applyingRatio ratio: CGFloat = 0.20) -> CGPoint {
        let translation = self.translation(in: view)

        guard let sourceView = self.view else {
            return translation
        }
        
        let updatedCenter = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        let distanceFromCenter = CGSize(width: abs(updatedCenter.x - sourceView.bounds.midX),
                                        height: abs(updatedCenter.y - sourceView.bounds.midY))
        
        let inverseRatio = 1.0 - ratio
        let scale: (x: CGFloat, y: CGFloat) = (updatedCenter.x < sourceView.bounds.midX ? -1 : 1, updatedCenter.y < sourceView.bounds.midY ? -1 : 1)
        let x = updatedCenter.x - (distanceFromCenter.width > limit.width ? inverseRatio * (distanceFromCenter.width - limit.width) * scale.x : 0)
        let y = updatedCenter.y - (distanceFromCenter.height > limit.height ? inverseRatio * (distanceFromCenter.height - limit.height) * scale.y : 0)

        return CGPoint(x: x, y: y)
    }
}
