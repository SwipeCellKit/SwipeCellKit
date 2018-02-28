//
//  SwipeActionSwitch.swift
//  SwipeCellKit
//
//  Created by Marco Filosi on 27/02/2018.
//

import Foundation

class SwipeActionSwitch: UISwitch {
    
    convenience init(action: SwipeAction) {
        self.init(frame: .zero)
        
        tintColor = action.textColor ?? .white
        onTintColor = action.highlightedTextColor ?? tintColor
        
        setOn(action.isOn ?? false, animated: false)
    }
    
}
