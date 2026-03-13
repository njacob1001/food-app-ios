import SwiftUI
import SwiftData

struct MenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dishes: [Dish]
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @Namespace private var namespace

    let categories = ["All", "Bajo en calorías", "Burgers", "Pasta", "Salads", "Desserts", "Drinks"]

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
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Almuerzos")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Elige entre los diferentes menús")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

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
                                    MenuItemRowView(dish: dish, namespace: namespace)
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
                MenuItemDetailView(dish: dish, namespace: namespace)
            }
            .toolbar {
                ToolbarItem(placement:.cancellationAction) {
                    Button {
                        // TODO: Navigate to profile
                    } label: {
                        Label("Profile", systemImage: "person.crop.circle.fill")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // TODO: Navigate to shopping cart
                    } label: {
                        Label("Cart", systemImage: "cart")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Buscar platos")
        
    }

    private func addSampleDishes() {
        withAnimation {
            for dish in Dish.sampleData {
                modelContext.insert(dish)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
    .modelContainer(for: Dish.self, inMemory: true)
}
