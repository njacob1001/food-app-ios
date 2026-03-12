//
//  Item.swift
//  food-app-ios
//
//  Created by Jacob Gonzalez on 12/03/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
