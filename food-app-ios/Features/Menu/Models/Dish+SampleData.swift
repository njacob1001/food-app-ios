import Foundation

extension Dish {
    static let sampleData: [Dish] = [
        Dish(
            name: "Margherita Pizza",
            description: "Classic pizza with tomato sauce, mozzarella, and fresh basil",
            price: 12.99,
            imageName: "https://picsum.photos/seed/pizza/400/300",
            category: "Pizza",
            rating: 4.8,
            preparationTime: 25
        ),
        Dish(
            name: "Cheeseburger Deluxe",
            description: "Juicy beef patty with cheddar cheese, lettuce, tomato, and special sauce",
            price: 10.99,
            imageName: "https://picsum.photos/seed/burger/400/300",
            category: "Burgers",
            rating: 4.6,
            preparationTime: 15
        ),
        Dish(
            name: "Spaghetti Carbonara",
            description: "Creamy pasta with pancetta, eggs, and parmesan cheese",
            price: 14.99,
            imageName: "https://picsum.photos/seed/pasta/400/300",
            category: "Pasta",
            rating: 4.9,
            preparationTime: 20
        ),
        Dish(
            name: "Caesar Salad",
            description: "Fresh romaine lettuce with parmesan, croutons, and Caesar dressing",
            price: 8.99,
            imageName: "https://picsum.photos/seed/salad/400/300",
            category: "Salads",
            rating: 4.5,
            preparationTime: 10
        ),
        Dish(
            name: "Chocolate Lava Cake",
            description: "Warm chocolate cake with a molten center, served with vanilla ice cream",
            price: 6.99,
            imageName: "https://picsum.photos/seed/cake/400/300",
            category: "Desserts",
            rating: 4.9,
            preparationTime: 12
        ),
        Dish(
            name: "Fresh Lemonade",
            description: "Homemade lemonade with fresh lemons and mint",
            price: 3.99,
            imageName: "https://picsum.photos/seed/drink/400/300",
            category: "Drinks",
            rating: 4.7,
            preparationTime: 5
        ),
    ]
}
