//
//  ScannerVC.swift
//  BarcodeScanner
//
//  Created by Almira Khafizova on 17.06.26.
//

import UIKit
import AVFoundation

enum CameraError: String {
  case invalidDeviceInput = "Something is wrong with the camera. We are unable to capture the input."
  case invalidScannedValue = "The value scanned is not valid. This app scans EAN-8 and EAN-13."
}

// A delegate for transmitting the found barcode to the outside
protocol ScannerVCDelegate: AnyObject {
  func didFind(barcode: String)
  func didSurface(error: CameraError)
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCaptureSession()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    guard let previewLayer = previewLayer else {
      scannerDelegate?.didSurface(error: .invalidDeviceInput)
      return
    }
    previewLayer.frame = view.layer.bounds
  }
  
  private func setupCaptureSession() {
    // Getting the device's physical camera
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
      scannerDelegate?.didSurface(error: .invalidDeviceInput)
      return
    }
    let videoInput: AVCaptureDeviceInput
    
    do {
      // Creating an Input for AVCaptureSession
      try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      scannerDelegate?.didSurface(error: .invalidDeviceInput)
      return
    }
    
    // Checking if it is possible to add input
    if captureSession.canAddInput(videoInput) {
      // Connecting the camera to the session
      captureSession.addInput(videoInput)
    } else {
      scannerDelegate?.didSurface(error: .invalidDeviceInput)
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
      scannerDelegate?.didSurface(error: .invalidDeviceInput)
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
      scannerDelegate?.didSurface(error: .invalidScannedValue)
      return
    }
    
    // Leading to the barcode type
    guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {
      scannerDelegate?.didSurface(error: .invalidScannedValue)
      return
    }
    
    // Getting the string value of the code
    guard let barcode = machineReadableObject.stringValue else {
      scannerDelegate?.didSurface(error: .invalidScannedValue)
      return
    }
    
    // Passing the found code outside
    scannerDelegate?.didFind(barcode: barcode)
  }
}

