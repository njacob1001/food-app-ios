import SwiftUI

struct MenuItemDetailView: View {
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
