//
//  SwipeTableViewCellDelegate.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

/**
 The `SwipeTableViewCellDelegate` protocol is adopted by an object that manages the display of action buttons when the cell is swiped.
 */
public protocol SwipeTableViewCellDelegate: AnyObject {
    
    /**
     Asks the delegate for the actions to display in response to a swipe in the specified row.
     
     - parameter tableView: The table view object which owns the cell requesting this information.
     
     - parameter indexPath: The index path of the row.
     
     - parameter orientation: The side of the cell requesting this information.
     
     - returns: An array of `SwipeAction` objects representing the actions for the row. Each action you provide is used to create a button that the user can tap.  Returning `nil` will prevent swiping for the supplied orientation.
     */
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]?
    
    /**
     Asks the delegate for the display options to be used while presenting the action buttons.
     
     - parameter tableView: The table view object which owns the cell requesting this information.
     
     - parameter indexPath: The index path of the row.
     
     - parameter orientation: The side of the cell requesting this information.
     
     - returns: A `SwipeOptions` instance which configures the behavior of the action buttons.
     
     - note: If not implemented, a default `SwipeOptions` instance is used.
     */
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions
    
    /**
     Tells the delegate that the table view is about to go into editing mode.

     - parameter tableView: The table view object providing this information.
     
     - parameter indexPath: The index path of the row.
     
     - parameter orientation: The side of the cell.
    */
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation)

    /**
     Tells the delegate that the table view has left editing mode.
     
     - parameter tableView: The table view object providing this information.
     
     - parameter indexPath: The index path of the row.
     
     - parameter orientation: The side of the cell.
     */
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation)
    
    /**
     Asks the delegate for visibile rectangle of the table view, which is used to ensure swipe actions are vertically centered within the visible portion of the cell.
     
     - parameter tableView: The table view object providing this information.
     
     - returns: The visible rectangle of the table view.
     
     - note: The returned rectange should be in the table view's own coordinate system. Returning `nil` will result in no vertical offset to be be calculated.
     */
    func visibleRect(for tableView: UITableView) -> CGRect?
}

/**
 Default implementation of `SwipeTableViewCellDelegate` methods
 */
public extension SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        return SwipeOptions()
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) {}
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {}
    
    func visibleRect(for tableView: UITableView) -> CGRect? {
        return nil
    }
}
