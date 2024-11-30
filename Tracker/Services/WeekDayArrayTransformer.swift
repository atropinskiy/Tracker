//
//  ScheduleTransformer.swift
//  Tracker
//
//  Created by alex_tr on 30.11.2024.
//

import Foundation

public class WeekDayArrayTransformer: ValueTransformer {

    override public func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([WeekDay].self, from: data as Data)
    }
    
    static func register() {
            ValueTransformer.setValueTransformer(
                WeekDayArrayTransformer(),
                forName: NSValueTransformerName(rawValue: String(describing: WeekDayArrayTransformer.self))
            )
        }
}






