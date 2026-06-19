//
//  ContentView.swift
//  BarcodeScanner
//
//  Created by Almira Khafizova on 17.06.26.
//

import SwiftUI

struct BarcodeScannerView: View {
  
  @StateObject var viewModel = BarcodeScannerViewModel()
  
  var body: some View {
    NavigationView {
      ZStack {
        LinearGradient(
          colors: [
            Color.blue.opacity(0.20),
            Color.purple.opacity(0.15),
            Color.indigo.opacity(0.10),
            Color.black.opacity(0.02)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack {
          ScannerView(scannedCode: $viewModel.scannedCode,
                      alertItem: $viewModel.alertItem)
          .frame(height: 280)
          .clipShape(RoundedRectangle(cornerRadius: 24))
          .overlay {
            RoundedRectangle(cornerRadius: 24)
              .stroke(.white.opacity(0.2), lineWidth: 1)
          }
          .shadow(radius: 10)
          .padding(.horizontal)
          
          Spacer().frame(height: 60)
          
          Label("Scanned Barcode", systemImage: "barcode.viewfinder")
            .font(.title)
          
          Text(viewModel.statusText)
            .bold()
            .font(.largeTitle)
            .foregroundStyle(viewModel.statusTextColor)
            .padding()
            .animation(.spring(), value: viewModel.statusText)
        }
        
        .navigationTitle("Barcode Scanner")
        .alert(item: $viewModel.alertItem) { alertItem in
          Alert(title: Text(alertItem.title),
                message: Text(alertItem.message),
                dismissButton: alertItem.dismissButton)
        }
      }
    }
  }
}

#Preview {
  BarcodeScannerView()
}
