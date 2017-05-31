//
//  SwipeAccessibilityCustomAction.swift
//  SwipeCellKit
//
//  Created by George Cox on 5/31/17.
//
//

import UIKit

class SwipeAccessibilityCustomAction: UIAccessibilityCustomAction {
  let action: SwipeAction
  let indexPath: IndexPath
  
  init(action: SwipeAction, indexPath: IndexPath, target: Any, selector: Selector) {
    guard let name = action.accessibilityLabel ?? action.title ?? action.image?.accessibilityIdentifier else {
      fatalError("You must provide either a title or an image for a SwipeAction")
    }
    
    self.action = action
    self.indexPath = indexPath
    
    super.init(name: name, target: target, selector: selector)
  }
}
