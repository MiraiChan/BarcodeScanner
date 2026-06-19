//
//  BarcodeScannerViewModel.swift
//  BarcodeScanner
//
//  Created by Almira Khafizova on 19.06.26.
//

import SwiftUI

final class BarcodeScannerViewModel: ObservableObject {
  @Published var scannedCode = ""
  @Published var alertItem: AlertItem?
  
  var statusText: String {
    scannedCode.isEmpty ? "Not Yet Scanned" : scannedCode
  }
  
  var statusTextColor: Color {
    scannedCode.isEmpty ? .red : .green
  }
}
