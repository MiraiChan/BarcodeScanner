//
//  ScannerVC.swift
//  BarcodeScanner
//
//  Created by Almira Khafizova on 17.06.26.
//

import UIKit
import AVFoundation

// A delegate for transmitting the found barcode to the outside
protocol ScannerVCDelegate: AnyObject {
  func didFind(barcode: String)
}

final class ScannerVC: UIViewController {
  // The central camera object. Input (camera, sourse of data) and output (scan result) are added to it.
  let captureSession = AVCaptureSession()
  
  // The layer that shows the camera image on the screen.
  var previewLayer: AVCaptureVideoPreviewLayer?
  weak var scannerDelegate: ScannerVCDelegate?
  
  init(scannerDelegate: ScannerVCDelegate) {
    super.init(nibName: nil, bundle: nil)
    
    // saving the delegate
    self.scannerDelegate = scannerDelegate
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")
  }
  
  private func setupCaptureSession() {
    // Getting the device's physical camera
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
      return
    }
    let videoInput: AVCaptureDeviceInput
    
    do {
      // Creating an Input for AVCaptureSession
      try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      return
    }
    
    // Checking if it is possible to add input
    if captureSession.canAddInput(videoInput) {
      // Connecting the camera to the session
      captureSession.addInput(videoInput)
    } else {
      return
    }
    
    // Output will output the found barcode objects.
    let metaDataOutput = AVCaptureMetadataOutput()
    
    // Checking if it is possible to add output
    if captureSession.canAddOutput(metaDataOutput) {
      
      // Adding the output to the session
      captureSession.addOutput(metaDataOutput)
      
      // All found codes will be sent to delegate
      metaDataOutput.setMetadataObjectsDelegate(
        self,
        queue: DispatchQueue.main
      )
      metaDataOutput.metadataObjectTypes = [.ean8, .ean13]
    } else {
      return
    }
    
    // Creating a visual representation of the camera
    previewLayer = AVCaptureVideoPreviewLayer(
      session: captureSession
    )
    guard let previewLayer else { return }
    previewLayer.videoGravity = .resizeAspectFill
    
    // Adding a camera layer to the screen
    view.layer.addSublayer(previewLayer)
    
    DispatchQueue.global(qos: .userInitiated).async {
      self.captureSession.startRunning()
    }
  }
}

extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(
    _ output: AVCaptureMetadataOutput,
    didOutput metadataObjects: [AVMetadataObject],
    from connection: AVCaptureConnection
  ) {
    // Taking the first object found
    guard let object = metadataObjects.first else {
      return
    }
    
    // Leading to the barcode type
    guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {
      return
    }
    
    // Getting the string value of the code
    guard let barcode = machineReadableObject.stringValue else {
      return
    }
    
    // Passing the found code outside
    scannerDelegate?.didFind(barcode: barcode)
  }
}

