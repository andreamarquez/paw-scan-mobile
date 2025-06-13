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
    let ingredients: [String]
    
    static let mock = Product(
        name: "Healthy Pet Food",
        barcode: "1234567890123",
        brand: "PetBrand",
        rating: 4,
        ingredients: ["Chicken", "Rice", "Carrots", "Vitamins"]
    )
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
                Text("Ingredients: \(product.ingredients.joined(separator: ", "))")
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
