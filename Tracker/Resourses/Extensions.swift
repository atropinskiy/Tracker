//
//  Extensions.swift
//  Tracker
//
//  Created by alex_tr on 29.10.2024.
//

import UIKit

extension UITextField {
    func setPadding(left: CGFloat = 0, right: CGFloat = 0) {
        if left > 0 {
            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.height))
            self.leftView = leftView
            self.leftViewMode = .always
        }
        
        if right > 0 {
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.height))
            self.rightView = rightView
            self.rightViewMode = .always
        }
    }
}
