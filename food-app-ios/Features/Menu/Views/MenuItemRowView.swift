import SwiftUI

struct MenuItemRowView: View {
    let dish: Dish
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 16) {
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

            VStack(alignment: .leading, spacing: 6) {
                Text(dish.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(dish.dishDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", dish.rating))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("\(dish.preparationTime) min")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)

                    Spacer()

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


extension Dish {
    static let preview = Dish(
        id: UUID(),
        name: "Pollo con arroz",
        description: "Porcion baja en calorías de pollo y arroz",
        price: 1900,
        imageName: "https://upload.wikimedia.org/wikipedia/commons/3/33/Fresh_made_pasta_juliane_fry.jpg",
        category: "some",
        rating: 4.7,
        preparationTime: 60,
        isAvailable: true
    )
}

private struct MenuItemRowPreview: View {
    @Namespace var animation

    var body: some View {
        MenuItemRowView(
            dish: .preview,
            namespace: animation
        )
        .padding()
    }
}

#Preview {
    MenuItemRowPreview()
}
