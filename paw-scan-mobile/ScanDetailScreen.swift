import SwiftUI

struct ScanDetailScreen: View {
    let product: Product?
    var body: some View {
        if let product = product {
            ScanDetailScreenImpl(product: product)
        } else {
            Text("No product data.")
                .navigationTitle("Product Overview")
        }
    }
}

struct ScanDetailScreenImpl: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIngredient: Ingredient? = nil
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Top Section – Product Overview
                    VStack(spacing: 12) {
                        if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                case .failure(_):
                                    ProductAvatarView(name: product.name)
                                @unknown default:
                                    ProductAvatarView(name: product.name)
                                }
                            }
                            .padding(.top, 16)
                        } else {
                            ProductAvatarView(name: product.name)
                                .padding(.top, 16)
                        }
                        Text(product.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text(product.brand)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            ForEach(0..<5) { i in
                                Image(systemName: i < Int(product.rating) ? "pawprint.fill" : "pawprint")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    Divider()
                    // Product Composition Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Product Composition")
                            .font(.headline)
                        ForEach(product.ingredients, id: \.id) { ingredient in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(ingredient.status.color)
                                Text(ingredient.name)
                                Spacer()
                                Button(action: { selectedIngredient = ingredient }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    // Bottom Navigation Buttons
                    HStack(spacing: 16) {
                        Button(action: { dismiss() }) {
                            Text("SCAN")
                                .font(.headline)
                                .frame(maxWidth: 200)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
//                        Button(action: { /* Navigate to History */ }) {
//                            Text("History")
//                                .font(.headline)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(12)
//                        }
//                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding([.horizontal, .bottom])
                }
                .padding()
            }
            // Custom pop-in modal overlay
            if let ingredient = selectedIngredient {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { selectedIngredient = nil }
                VStack(spacing: 24) {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(ingredient.status.color)
                        .padding(.top, 24)
                    Text(ingredient.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(ingredient.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button(action: { selectedIngredient = nil }) {
                        Text("Close")
                            .font(.headline)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: 320)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.scale)
                .zIndex(2)
            }
        }
        .navigationTitle("Product Overview")
    }
}

struct ProductAvatarView: View {
    let name: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 100, height: 100)
            Text(String(name.prefix(1)).uppercased())
                .font(.largeTitle)
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    ScanDetailScreenImpl(product: Product.mock)
}
