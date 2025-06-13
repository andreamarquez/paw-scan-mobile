import SwiftUI

struct ScanDetailScreen: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            // Top Section – Product Overview
            VStack(spacing: 12) {
                Image("product_placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(radius: 4)
                    .padding(.top, 24)
                Text(product.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text(product.brand)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < product.rating ? "pawprint.fill" : "pawprint")
                            .foregroundColor(.orange)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 16)
            
            // Middle Section – Ingredients List
            VStack(alignment: .leading, spacing: 8) {
                Text("Ingredients")
                    .font(.headline)
                    .padding(.bottom, 4)
                ForEach(product.ingredients, id: \.name) { ingredient in
                    HStack {
                        Image(systemName: ingredient.status.iconName)
                            .foregroundColor(ingredient.status.color)
                        Text(ingredient.name)
                            .font(.body)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            Spacer()
            
            // Bottom Navigation Buttons
            HStack(spacing: 16) {
                Button(action: {
                    dismiss()
                }) {
                    Text("SCAN")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                Button(action: { /* Navigate to History */ }) {
                    Text("History")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("Product Overview")
    }
}

//struct Product {
//    let name: String
//    let brand: String
//    let rating: Int // 0-5
//    let ingredients: [Ingredient]
//}

#Preview {
    ScanDetailScreen(product: Product(
        name: "Organic Dog Food",
        barcode: "1234567890123",
        brand: "HealthyPets Co.",
        rating: 3,
        ingredients: [
            Ingredient(name: "Chicken", status: .safe),
            Ingredient(name: "Corn", status: .caution),
            Ingredient(name: "Artificial Color", status: .unsafe),
            Ingredient(name: "Rice", status: .safe),
            Ingredient(name: "Salt", status: .caution)
        ]
    ))
}
