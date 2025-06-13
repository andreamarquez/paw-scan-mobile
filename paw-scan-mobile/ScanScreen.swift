import SwiftUI

struct ScanScreen: View {
    @State private var isScanning = false
    @State private var showScanDetail = false
    @State private var scannedProduct: Product? = nil
    @State private var scanError: ScanError? = nil // Use ScanError struct

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(systemName: "barcode.viewfinder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 220, height: 220)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
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
                    destination: scannedProduct.map { ScanDetailScreen(product: $0) },
                    isActive: $showScanDetail,
                    label: { EmptyView() }
                )
                .hidden()
            )
            .alert(item: $scanError) { error in
                Alert(title: Text("Scan Failed"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    func startScan() {
        isScanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//            if Bool.random() {
//                scannedProduct = Product.mock
//                isScanning = false
//                showScanDetail = true
//            } else {
//                scannedProduct = nil
//                isScanning = false
//                scanError = ScanError(message: "Could not scan product. Please try again.")
//            }
            scannedProduct = Product.mock
            isScanning = false
            showScanDetail = true
        }
    }
}

// MARK: - Error Wrapper

struct ScanError: Identifiable {
    let id = UUID()
    let message: String
}


// MARK: - Mock Models and Screens

struct Ingredient: Hashable {
    let name: String
    let status: IngredientStatus
}

enum IngredientStatus {
    case safe, unsafe, caution
    var iconName: String {
        switch self {
        case .safe: return "checkmark.circle.fill"
        case .unsafe: return "xmark.octagon.fill"
        case .caution: return "exclamationmark.triangle.fill"
        }
    }
    var color: Color {
        switch self {
        case .safe: return .green
        case .unsafe: return .red
        case .caution: return .yellow
        }
    }
}

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let barcode: String
    let brand: String
    let rating: Int
    let ingredients: [Ingredient]
    
    static let mock = Product(
        name: "Healthy Pet Food",
        barcode: "1234567890123",
        brand: "PetBrand",
        rating: 4,
        ingredients: [
            Ingredient(name: "Chicken", status: .safe),
            Ingredient(name: "Rice", status: .safe),
            Ingredient(name: "Carrots", status: .caution),
            Ingredient(name: "Vitamins", status: .safe)
        ]
    )
}

//struct ScanDetailScreen: View {
//    let product: Product?
//    var body: some View {
//        VStack {
//            if let product = product {
//                Text(product.name)
//                    .font(.title)
//                Text("Brand: \(product.brand)")
//                Text("Rating: \(product.rating) paws")
//                Text("Ingredients: \(product.ingredients.joined(separator: ", "))")
//            } else {
//                Text("No product data.")
//            }
//        }
//        .navigationTitle("Product Overview")
//    }
//}

struct HistoryScreen: View {
    var body: some View {
        Text("History Screen (mock)")
            .navigationTitle("History")
    }
}

#Preview {
    ScanScreen()
}
