//
//  Static.swift
//  Tracker
//
//  Created by alex_tr on 29.10.2024.
//

import UIKit


let collectionColors: [UIColor] = [
    UIColor(hex: "#FD4C49")!,
    UIColor(hex: "#FF881E")!,
    UIColor(hex: "#007BFA")!,
    UIColor(hex: "#6E44FE")!,
    UIColor(hex: "#33CF69")!,
    UIColor(hex: "#E66DD4")!,
    UIColor(hex: "#F9D4D4")!,
    UIColor(hex: "#34A7FE")!,
    UIColor(hex: "#46E69D")!,
    UIColor(hex: "#35347C")!,
    UIColor(hex: "#FF674D")!,
    UIColor(hex: "#FF99CC")!,
    UIColor(hex: "#F6C48B")!,
    UIColor(hex: "#7994F5")!,
    UIColor(hex: "#832CF1")!,
    UIColor(hex: "#AD56DA")!,
    UIColor(hex: "#8D72E6")!,
    UIColor(hex: "#2FD058")!,
]

let collectionEmojies: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]

let testTrackers: [Tracker] = [
    Tracker(id: UUID(), name: "Тестовый трекер", color: collectionColors[1], emoji: collectionEmojies[1], schedule: [.thursday]),
    Tracker(id: UUID(), name: "Тестовый трекер", color: collectionColors[2], emoji: collectionEmojies[2], schedule: [.wednesday]),
    Tracker(id: UUID(), name: "Тестовый трекер", color: collectionColors[3], emoji: collectionEmojies[3], schedule: [.friday]),
    Tracker(id: UUID(), name: "Тестовый трекер", color: collectionColors[4], emoji: collectionEmojies[4], schedule: [.thursday]),
    Tracker(id: UUID(), name: "Тестовый трекер", color: collectionColors[5], emoji: collectionEmojies[5], schedule: [.thursday]),
]


