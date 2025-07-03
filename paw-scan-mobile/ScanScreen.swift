import SwiftUI
import AVFoundation

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
                Button(action: { showScanner = true }) {
                    Text("Scan Product")
                        .font(.headline)
                        .frame(maxWidth: 250)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
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
            .fullScreenCover(isPresented: $showScanner) {
                BarcodeScannerView { code in
                    showScanner = false
                    // Here you would fetch product by barcode from backend
                    // For now, mock: if code matches mock, show detail, else error
                    if code == Product.mock.barcode {
                        scannedProduct = Product.mock
                        showScanDetail = true
                    } else {
                        scanError = ScanError(message: "Product not found for barcode: \(code)")
                    }
                }
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


// MARK: - IngredientStatus and Ingredient

enum IngredientStatus: String, Codable {
    case excellent, good, fair, poor
    
    var color: Color {
        switch self {
        case .excellent: return Color.green.opacity(0.8)                  // Kept the green
        case .good: return Color.green.opacity(0.3)     // Same green but faded
        case .fair: return Color.red.opacity(0.3)       // Red but faded
        case .poor: return Color.red.opacity(0.8)           // Kept the red
        }
    }
}

struct Ingredient: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let status: IngredientStatus
    let description: String
}

struct Product: Identifiable, Codable {
    let id = UUID()
    let name: String
    let barcode: String
    let brand: String
    let rating: Int
    let ingredients: [Ingredient]
    static let mock = Product(
        name: "Healthy Pet Food",
        barcode: "3337875803786",
        brand: "PetBrand",
        rating: 4,
        ingredients: [
            Ingredient(name: "Chicken", status: .excellent, description: "High-quality protein source."),
            Ingredient(name: "Rice", status: .good, description: "Easily digestible carbohydrate."),
            Ingredient(name: "Carrots", status: .excellent, description: "Rich in vitamins and fiber."),
            Ingredient(name: "Vitamins", status: .excellent, description: "Essential nutrients for health."),
            Ingredient(name: "Chemical X", status: .fair, description: "May give superpowers."),
            Ingredient(name: "Artificial Color", status: .poor, description: "Not recommended for pets.")
        ]
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
