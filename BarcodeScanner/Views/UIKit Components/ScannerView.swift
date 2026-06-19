//
//  ScannerView.swift
//  BarcodeScanner
//
//  Created by Almira Khafizova on 18.06.26.
//

import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
  
  @Binding var scannedCode: String
  @Binding var alertItem: AlertItem?
  
  func makeUIViewController(context: Context) -> ScannerVC {
    ScannerVC(scannerDelegate: context.coordinator)
  }
  
  func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(scannerView: self)
  }
  
  final class Coordinator: NSObject, ScannerVCDelegate {
    
    private let scannerView: ScannerView
    
    init(scannerView: ScannerView) {
      self.scannerView = scannerView
    }
    
    func didSurface(error: CameraError) {
      switch error {
      case .invalidDeviceInput:
        scannerView.alertItem = AlertContext.invalidDeviceInput
      case .invalidScannedValue:
        scannerView.alertItem = AlertContext.invalidScannedType
      }
    }
    
    func didFind(barcode: String) {
      scannerView.scannedCode = barcode
    }
  }
}
