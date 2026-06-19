# Barcode Scanner (SwiftUI + UIKit Bridge)

This demo demonstrates how to integrate UIKit (AVFoundation barcode scanning) into a SwiftUI application using UIViewControllerRepresentable and a Coordinator as a communication bridge.

The main focus is how SwiftUI and UIKit communicate in a hybrid architecture.

---

# Architecture

- SwiftUI → UI layer
- BarcodeScannerViewModel → state management
- ScannerView (UIViewControllerRepresentable) → bridge between SwiftUI and UIKit
- ScannerVC (UIKit + AVFoundation) → camera and barcode scanning
- Coordinator → communication layer between UIKit and SwiftUI

---

# SwiftUI ↔ UIKit Communication

SwiftUI sends data to UIKit using @Binding:

ScannerView(
  scannedCode: $viewModel.scannedCode,
  alertItem: $viewModel.alertItem
)

This allows UIKit to update SwiftUI state directly.

UIKit communicates back using a delegate pattern:

protocol ScannerVCDelegate: AnyObject {
  func didFind(barcode: String)
  func didSurface(error: CameraError)
}

The Coordinator implements this protocol and updates SwiftUI bindings.

---

# Data Flow

SwiftUI View → ViewModel (@Published state) → ScannerView (UIViewControllerRepresentable) → Coordinator (Delegate bridge) → ScannerVC (UIKit + AVFoundation) → Barcode detected / error → Coordinator updates SwiftUI state → UI updates automatically

---

# ScannerVC (UIKit Layer)

Built using AVFoundation:
- AVCaptureSession (camera input)
- AVCaptureMetadataOutput (barcode detection)
- AVCaptureVideoPreviewLayer (camera preview)

Supported formats:
- EAN-8
- EAN-13

---

# ViewModel

Responsible for application state:
- scannedCode
- alertItem

Computed UI:
- statusText
- statusTextColor

---

# Coordinator

Acts as a bridge between UIKit and SwiftUI:
- Receives delegate callbacks from ScannerVC
- Updates @Binding properties
- Maps errors into SwiftUI alerts

---

# Key Concept

SwiftUI and UIKit cannot communicate directly.

This project uses:
- UIViewControllerRepresentable
- Coordinator
- Delegate pattern
- @Binding

to safely connect both frameworks.

---

# Tech Stack

SwiftUI  
UIKit  
AVFoundation  
MVVM  
Delegate pattern  
UIViewControllerRepresentable

---

# Screenshot

<img width="590" height="1280" alt="photo_2026-06-20 00 23 50" src="https://github.com/user-attachments/assets/8dda860f-761d-4a1d-8f2e-c4334ed4af89" />
