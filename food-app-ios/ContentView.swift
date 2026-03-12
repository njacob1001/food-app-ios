//
//  ContentView.swift
//  food-app-ios
//
//  Created by Jacob Gonzalez on 12/03/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dishes: [Dish]
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @Namespace private var namespace
    
    let categories = ["All", "Pizza", "Burgers", "Pasta", "Salads", "Desserts", "Drinks"]
    
    var filteredDishes: [Dish] {
        var result = dishes
        
        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }
        
        if !searchText.isEmpty {
            result = result.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.dishDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Food Delivery")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Order your favorite dishes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                CategoryButton(
                                    title: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    withAnimation {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Dishes List
                    if filteredDishes.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "fork.knife.circle")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            
                            Text("No dishes available")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Add some dishes to get started")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Button(action: addSampleDishes) {
                                Label("Add Sample Dishes", systemImage: "plus.circle.fill")
                                    .font(.headline)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredDishes) { dish in
                                NavigationLink(value: dish) {
                                    DishRowView(dish: dish, namespace: namespace)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationDestination(for: Dish.self) { dish in
                DishDetailView(dish: dish, namespace: namespace)
            }
            .searchable(text: $searchText, prompt: "Search dishes")
            .toolbar {
                ToolbarItem {
                    Button(action: addSampleDishes) {
                        Label("Add Dishes", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func addSampleDishes() {
        let sampleDishes = [
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
            )
        ]
        
        withAnimation {
            for dish in sampleDishes {
                modelContext.insert(dish)
            }
        }
    }
}

// MARK: - Dish Row View
struct DishRowView: View {
    let dish: Dish
    var namespace: Namespace.ID
    
    var body: some View {
        HStack(spacing: 16) {
            // Dish Image with hero animation
            AsyncImage(url: URL(string: dish.imageName)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .matchedGeometryEffect(id: "image-\(dish.id)", in: namespace)
                case .failure:
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                        .frame(width: 80, height: 80)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                @unknown default:
                    EmptyView()
                }
            }
            
            // Dish Info
            VStack(alignment: .leading, spacing: 6) {
                Text(dish.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(dish.dishDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", dish.rating))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    // Preparation Time
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("\(dish.preparationTime) min")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Price
                    Text("$\(String(format: "%.2f", dish.price))")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Dish Detail View
struct DishDetailView: View {
    let dish: Dish
    var namespace: Namespace.ID
    @State private var quantity = 1
    @Environment(\.dismiss) private var dismiss
    
    var totalPrice: Double {
        dish.price * Double(quantity)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Dish Image with hero animation
                AsyncImage(url: URL(string: dish.imageName)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .matchedGeometryEffect(id: "image-\(dish.id)", in: namespace)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // Dish Info
                VStack(alignment: .leading, spacing: 16) {
                    Text(dish.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", dish.rating))
                                .fontWeight(.semibold)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("\(dish.preparationTime) min")
                        }
                        .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .font(.subheadline)
                    
                    Text("About")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    Text(dish.dishDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Quantity Selector
                    HStack {
                        Text("Quantity")
                            .font(.headline)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button {
                                if quantity > 1 {
                                    withAnimation(.spring(response: 0.3)) {
                                        quantity -= 1
                                    }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(quantity > 1 ? .primary : .secondary)
                            }
                            .disabled(quantity <= 1)
                            
                            Text("\(quantity)")
                                .font(.headline)
                                .frame(minWidth: 30)
                            
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    quantity += 1
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Add to Cart Button
                Button {
                    // Add to cart action
                } label: {
                    HStack {
                        Text("Add to Cart")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", totalPrice))")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Dish.self, inMemory: true)
}
