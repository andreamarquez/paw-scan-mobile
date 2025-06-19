import SwiftUI

struct ScanDetailScreen: View {
    let product: Product
    @State private var selectedIngredient: Ingredient? = nil
    @State private var selectedSubcategory: EvaluationSubcategory? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top Section – Product Overview
                VStack(spacing: 12) {
                    Image(systemName: product.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.top, 16)
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
                Divider()
                // Middle Section – Ingredients List
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.headline)
                    ForEach(product.ingredients) { ingredient in
                        HStack {
                            Image(systemName: ingredient.status.icon)
                                .foregroundColor(ingredient.status.color)
                            Text(ingredient.name)
                            Spacer()
                            Button(action: { selectedIngredient = ingredient }) {
                                Image(systemName: "info.circle")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                Divider()
                // Bottom Section – Food Evaluation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Food Evaluation")
                        .font(.headline)
                    ForEach(product.evaluation) { subcat in
                        HStack {
                            Image(systemName: subcat.status.icon)
                                .foregroundColor(subcat.status.color)
                            Text(subcat.name)
                            Spacer()
                            Button(action: { selectedSubcategory = subcat }) {
                                Image(systemName: "info.circle")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Product Overview")
        .sheet(item: $selectedIngredient) { ingredient in
            InfoModalView(title: ingredient.name, description: ingredient.description, status: ingredient.status)
        }
        .sheet(item: $selectedSubcategory) { subcat in
            InfoModalView(title: subcat.name, description: subcat.description, status: subcat.status)
        }
    }
}

struct InfoModalView: View {
    let title: String
    let description: String
    let status: IngredientStatus
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: status.icon)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(status.color)
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        ScanDetailScreen(product: Product.mock)
    }
}
