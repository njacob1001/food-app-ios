import SwiftUI

struct MenuItemRowView: View {
    let dish: Dish
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: dish.imageName)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 100)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100)
                        .clipped()
                        .matchedGeometryEffect(id: "image-\(dish.id)", in: namespace)
                case .failure:
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: 100)
                        .background(Color.white.opacity(0.1))
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(dish.name)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(dish.dishDescription)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", dish.rating))
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.yellow)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("\(dish.preparationTime) min")
                    }
                    .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    Text("$\(String(format: "%.2f", dish.price))")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .font(.caption)
            }
            .padding(.vertical, 12)
            .padding(.trailing, 12)
        }
        .frame(height: 100)
        .background {
            ZStack {
                Color.black.opacity(0.6)
                AsyncImage(url: URL(string: dish.imageName)) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 20)
                            .overlay(Color.black.opacity(0.4))
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


extension Dish {
    static let preview = Dish(
        id: UUID(),
        name: "Pollo con arroz",
        description: "Porcion baja en calorías de pollo y arroz",
        price: 1900,
        imageName: "https://picsum.photos/id/312/400/400",
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
