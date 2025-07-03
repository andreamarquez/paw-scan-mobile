import SwiftUI
import AVFoundation

// Centralized API base URL
struct API {
    // static var baseURL = "http://localhost:3000/api/v1"
    static var baseURL = "https://usable-instantly-eagle.ngrok-free.app/api/v1"
}

struct BarcodeScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView
        init(parent: BarcodeScannerView) { self.parent = parent }
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let code = metadataObject.stringValue {
                parent.completion(code)
            }
        }
    }
    var completion: (String) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let session = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return controller }
        let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        if let videoInput = videoInput, session.canAddInput(videoInput) { session.addInput(videoInput) }
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) { session.addOutput(metadataOutput) }
        metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .qr, .code128, .upce, .code39, .code93, .pdf417, .aztec, .dataMatrix, .itf14]
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
        controller.view.layer.addSublayer(previewLayer)
        session.startRunning()
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ScanScreen: View {
    @State private var isScanning = false
    @State private var showScanDetail = false
    @State private var scannedProduct: Product? = nil
    @State private var scanError: ScanError? = nil
    @State private var showScanner = false
    @State private var lastScanTime: Date? = nil

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
                Button(action: { if !isScanning && scanError == nil { showScanner = true } }) {
                    Text("Scan Product")
                        .font(.headline)
                        .frame(maxWidth: 250)
                        .padding()
                        .background((isScanning || scanError != nil) ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .disabled(isScanning || scanError != nil)
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
                Alert(title: Text("Scan Failed"), message: Text(error.message), dismissButton: .default(Text("OK"), action: {
                    // Allow scanning again after alert is dismissed
                    isScanning = false
                }))
            }
            .fullScreenCover(isPresented: $showScanner) {
                BarcodeScannerView { code in
                    showScanner = false
                    // Debounce: Only allow a scan every 1.5 seconds
                    let now = Date()
                    if let last = lastScanTime, now.timeIntervalSince(last) < 1.5 {
                        return
                    }
                    lastScanTime = now
                    if !isScanning && scanError == nil {
                        isScanning = true
                        fetchProduct(barcode: code)
                    }
                }
            }
        }
    }

    func fetchProduct(barcode: String) {
        guard let url = URL(string: "\(API.baseURL)/products/\(barcode)") else {
            if scanError == nil {
                scanError = ScanError(message: "Invalid backend URL")
            }
            isScanning = false
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    if scanError == nil {
                        scanError = ScanError(message: "Network error: \(error.localizedDescription)")
                    }
                    isScanning = false
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    if scanError == nil {
                        scanError = ScanError(message: "No data from server")
                    }
                    isScanning = false
                }
                return
            }
            do {
                let apiResponse = try JSONDecoder().decode(ProductAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    if let product = apiResponse.data {
                        scannedProduct = product
                        showScanDetail = true
                    } else {
                        if scanError == nil {
                            scanError = ScanError(message: "Product not found for barcode: \(barcode)")
                        }
                    }
                    isScanning = false
                }
            } catch {
                DispatchQueue.main.async {
                    if scanError == nil {
                        scanError = ScanError(message: "Failed to parse product data: \(error.localizedDescription)")
                    }
                    isScanning = false
                }
            }
        }
        task.resume()
    }
}

// MARK: - API Response Wrapper
struct ProductAPIResponse: Codable {
    let data: Product?
}

// MARK: - Error Wrapper

struct ScanError: Identifiable {
    let id = UUID()
    let message: String
}


// MARK: - IngredientStatus and Ingredient

enum IngredientStatus: String, Codable {
    case excellent, good, fair, poor
    
    var color: Color {
        switch self {
        case .excellent: return Color.green.opacity(0.8)
        case .good: return Color.green.opacity(0.3)
        case .fair: return Color.red.opacity(0.3)
        case .poor: return Color.red.opacity(0.8)
        }
    }
}

struct Ingredient: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let status: IngredientStatus
    let description: String
}

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let barcode: String?
    let brand: String
    let rating: Double
    let ingredients: [Ingredient]
    let imageUrl: String?
    let description: String?
    // Example mock for preview/testing
    static let mock = Product(
        id: "11111111-1111-1111-1111-111111111111",
        name: "Healthy Pet Food",
        barcode: "3337875803786",
        brand: "PetBrand",
        rating: 4.0,
        ingredients: [
            Ingredient(id: "1", name: "Chicken", status: .excellent, description: "High-quality protein source."),
            Ingredient(id: "2", name: "Rice", status: .good, description: "Easily digestible carbohydrate."),
            Ingredient(id: "3", name: "Carrots", status: .excellent, description: "Rich in vitamins and fiber."),
            Ingredient(id: "4", name: "Vitamins", status: .excellent, description: "Essential nutrients for health."),
            Ingredient(id: "5", name: "Chemical X", status: .fair, description: "May give superpowers."),
            Ingredient(id: "6", name: "Artificial Color", status: .poor, description: "Not recommended for pets.")
        ],
        imageUrl: nil,
        description: "A healthy and nutritious pet food."
    )
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
