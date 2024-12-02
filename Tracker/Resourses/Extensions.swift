//
//  Extensions.swift
//  Tracker
//
//  Created by alex_tr on 29.10.2024.
//

import UIKit
import CoreData

extension UITextField {
    func safeSetPadding(left: CGFloat = 0, right: CGFloat = 0) {
        guard !left.isNaN, !right.isNaN else {
            print("Invalid padding values: left=\(left), right=\(right)")
            return
        }
        
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

extension UIColor {
    convenience init?(hex: String) {
        var rgb: UInt64 = 0
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Убедитесь, что строка начинается с символа '#'
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex) // Удаляем знак #
        }
        
        // Проверяем, является ли строка корректной длины
        guard hexString.count == 6 || hexString.count == 8 else { return nil }
        
        // Преобразуем строку в целое число
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        // Если есть альфа-канал
        let alpha: CGFloat = hexString.count == 8 ? CGFloat((rgb & 0xFF)) / 255.0 : 1.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    func toHex() -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255)
            return String(format: "#%06x", rgb)
        } else {
            return nil
        }
    }
}


