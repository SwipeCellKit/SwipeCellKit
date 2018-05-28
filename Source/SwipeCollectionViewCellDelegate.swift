//
//  SwipeCollectionViewCellDelegate.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

/**
 The `SwipeCollectionViewCellDelegate` protocol is adopted by an object that manages the display of action buttons when the item is swiped.
 */
public protocol SwipeCollectionViewCellDelegate: class {
    /**
     Asks the delegate for the actions to display in response to a swipe in the specified item.
     
     - parameter collectionView: The collection view object which owns the item requesting this information.
     
     - parameter indexPath: The index path of the item.
     
     - parameter orientation: The side of the item requesting this information.
     
     - returns: An array of `SwipeAction` objects representing the actions for the item. Each action you provide is used to create a button that the user can tap.  Returning `nil` will prevent swiping for the supplied orientation.
     */
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]?
    
    /**
     Asks the delegate for the display options to be used while presenting the action buttons.
     
     - parameter collectionView: The collection view object which owns the item requesting this information.
     
     - parameter indexPath: The index path of the item.
     
     - parameter orientation: The side of the item requesting this information.
     
     - returns: A `SwipeOptions` instance which configures the behavior of the action buttons.
     
     - note: If not implemented, a default `SwipeOptions` instance is used.
     */
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions
    
    /**
     Tells the delegate that the collection view is about to go into editing mode.
     
     - parameter collectionView: The collection view object providing this information.
     
     - parameter indexPath: The index path of the item.
     
     - parameter orientation: The side of the item.
     */
    func collectionView(_ collectionView: UICollectionView, willBeginEditingItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation)
    
    /**
     Tells the delegate that the collection view has left editing mode.
     
     - parameter collectionView: The collection view object providing this information.
     
     - parameter indexPath: The index path of the item.
     
     - parameter orientation: The side of the item.
     */
    func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation)
    
    /**
     Asks the delegate for visibile rectangle of the collection view, which is used to ensure swipe actions are vertically centered within the visible portion of the item.
     
     - parameter collectionView: The collection view object providing this information.
     
     - returns: The visible rectangle of the collection view.
     
     - note: The returned rectange should be in the collection view's own coordinate system. Returning `nil` will result in no vertical offset to be be calculated.
     */
    func visibleRect(for collectionView: UICollectionView) -> CGRect?
}

/**
 Default implementation of `SwipeCollectionViewCellDelegate` methods
 */
public extension SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        return SwipeOptions()
    }
    
    func collectionView(_ collectionView: UICollectionView, willBeginEditingItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) {}
    
    func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {}
    
    func visibleRect(for collectionView: UICollectionView) -> CGRect? {
        return nil
    }
}
