import Foundation
import SwiftData

@Model
final class Dish {
    var id: UUID
    var name: String
    var dishDescription: String
    var price: Double
    var imageName: String
    var category: String
    var rating: Double
    var preparationTime: Int // in minutes
    var isAvailable: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        price: Double,
        imageName: String,
        category: String,
        rating: Double = 4.5,
        preparationTime: Int = 30,
        isAvailable: Bool = true
    ) {
        self.id = id
        self.name = name
        self.dishDescription = description
        self.price = price
        self.imageName = imageName
        self.category = category
        self.rating = rating
        self.preparationTime = preparationTime
        self.isAvailable = isAvailable
    }
}
