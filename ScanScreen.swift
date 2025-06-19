import SwiftUI

struct ScanScreen: View {
    @State private var isScanning = false
    @State private var showScanDetail = false
    @State private var scannedProduct: Product? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                // Mock barcode image
                Image(systemName: "barcode.viewfinder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 220, height: 220)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
                
                // Scan button
                Button(action: startScan) {
                    Text(isScanning ? "Scanning..." : "Scan Product")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isScanning ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(isScanning)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // History button
                NavigationLink(destination: HistoryScreen()) {
                    Text("View History")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle("Scan")
            .background(
                NavigationLink(
                    destination: ScanDetailScreen(product: scannedProduct),
                    isActive: $showScanDetail,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
    }
    
    func startScan() {
        isScanning = true
        // Simulate a network delay and response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            // Mock product data
            scannedProduct = Product.mock
            isScanning = false
            showScanDetail = true
        }
    }
}

// MARK: - Mock Models and Screens

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let barcode: String
    let brand: String
    let rating: Int
    let type: ProductType
    let ingredients: [Ingredient]?
    let foodEvaluation: [SubcategoryModalState]?
    
    static let mock = Product(
        name: "Healthy Pet Food",
        barcode: "1234567890123",
        brand: "PetBrand",
        rating: 4,
        type: .petFood,
        ingredients: [
            Ingredient(name: "Chicken", status: .safe, description: "High-quality protein source."),
            Ingredient(name: "Rice", status: .safe, description: "Easily digestible carbohydrate."),
            Ingredient(name: "Carrots", status: .safe, description: "Rich in vitamins and fiber."),
            Ingredient(name: "Vitamins", status: .safe, description: "Essential nutrients for health."),
            Ingredient(name: "Artificial Color", status: .unsafe, description: "Not recommended for pets.")
        ],
        foodEvaluation: nil
    )
    static let mockSupply = Product(
        name: "Pet Water Bowl",
        barcode: "9876543210987",
        brand: "PetBrand",
        rating: 5,
        type: .petSupply,
        ingredients: nil,
        foodEvaluation: [
            SubcategoryModalState(name: "Material Safety", description: "Safe for pets to use.", status: .safe),
            SubcategoryModalState(name: "Durability", description: "Long-lasting and sturdy.", status: .safe),
            SubcategoryModalState(name: "Ease of Cleaning", description: "Easy to clean and maintain.", status: .safe)
        ]
    )
}

enum ProductType: String, Codable {
    case petFood, petSupply
}

struct Ingredient {
    let name: String
    let status: SafetyStatus
    let description: String
}

enum SafetyStatus {
    case safe, unsafe
}

struct SubcategoryModalState {
    let name: String
    let description: String
    let status: SafetyStatus
}

struct ScanDetailScreen: View {
    let product: Product?
    var body: some View {
        VStack {
            if let product = product {
                Text(product.name)
                    .font(.title)
                Text("Brand: \(product.brand)")
                Text("Rating: \(product.rating) paws")
                if let ingredients = product.ingredients {
                    Text("Ingredients: \(ingredients.map { $0.name }.joined(separator: ", "))")
                }
            } else {
                Text("No product data.")
            }
        }
        .navigationTitle("Product Overview")
    }
}

struct HistoryScreen: View {
    var body: some View {
        Text("History Screen (mock)")
            .navigationTitle("History")
    }
}

#Preview {
    ScanScreen()
}
