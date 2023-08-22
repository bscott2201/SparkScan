//
//  ContentView.swift
//  SparkScan
//
//  Created by Brad Scott on 8/22/23.
//

import SwiftUI
import ScanditBarcodeCapture


struct SparkScanRepresentableView: UIViewRepresentable {
    let context: DataCaptureContext
    let sparkScan: SparkScan
    var sparkScanView: SparkScanView!
    
    func makeUIView(context: Context) -> UIView {
        let dummyParentView = UIView()
        let viewSettings = SparkScanViewSettings()
        sparkScanView = SparkScanView(parentView: dummyParentView, context: self.context, sparkScan: self.sparkScan, settings: viewSettings) // <-- Use the stored property directly
        dummyParentView.addSubview(sparkScanView)
        sparkScanView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sparkScanView.topAnchor.constraint(equalTo: dummyParentView.topAnchor),
            sparkScanView.bottomAnchor.constraint(equalTo: dummyParentView.bottomAnchor),
            sparkScanView.leadingAnchor.constraint(equalTo: dummyParentView.leadingAnchor),
            sparkScanView.trailingAnchor.constraint(equalTo: dummyParentView.trailingAnchor)
        ])
        return dummyParentView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}



struct ScannedItemsList: View {
    @Binding var items: [String]
    
    var body: some View {
        List(items, id: \.self) { item in
            Text("List Of Things")
                .foregroundColor(.white)
            Text(item)
        }
    }
}


struct ContentView: View {
    @StateObject private var sparkScanDelegate = SparkScanDelegate()
    private let context: DataCaptureContext
    private let sparkScan: SparkScan
    
    init() {
        // Initialize and configure SparkScan
        context = DataCaptureContext(licenseKey: "AWSTCjqfHhg/Ip+PXwcgLXInQkDtGo074XOFXDZbTyUIaLkmP0wgSDV5mZAlSBSoWQnPFkRf+hvVfXvMolepaJxl2bWGe9Gtqx81E5FQQwXgNO90R2+NrC9gQvRIRghsvzw/L6wdXRv6DLrBthn/gt6hm7z7npeiENG8pD0fifw6aMlJ5T+ze0OqcizMKZFXy4sKtZKsueeIbrU22+XoWHJOdm3cyQhG938L+b8hAFO63AzY585lBnfoYcT0Ipas+1C+wQvwvOplv34iWpm+x01DXkoYyNSWHk7O/eh95rFKRRPoJ8gEX5q3fVrDvRutdSTEUPK9X9ESNnVMYrbnJENYHe43bEeVddDoKH9GkLqAxe7nNfBT0M5YaMCX4Y0CPoyctVHq6ytezHeADn0GGRCgQf/3CPnU0eqFInmrPpreJngbHYnVIINAlEalHBvOqiXGMu13+dbDCbo/C4xA64weWO7+uW3SYEMAJqwavYLUnUDgFSlf9K7pQXRRiMBb9k6Adp80ZNJEVXndiBZ/epjsXRKCEOqb4C8zwudwsNrZlGsK+kA/hB0OB+j2A4W1iajvcgWm6xGYIpUWkDu/dTqbpn2zfKjmipbg4Sz5CLmmMCj3O1NPsNoFyV16FiVcGRIRb9KGijjc4eBlm80PfwyWovNhe2QEcJTVEdHM/al7zvxXj0VF1Q3rhz09PwKA1Ad+/KSan+KUfEpjmH2mfvAolG4lVGU+hMVT6wTVjcYs5gRMxWCdGcHVy07p9S2+jTXH04KHVhc7gw4JZYjuvCbDFRz0JKxcE7XtxkbKS9f0M+WDI74U/GifXgM=")
        let settings = SparkScanSettings()
        settings.set(symbology: .ean13UPCA, enabled: true)
        sparkScan = SparkScan(settings: settings)
        sparkScan.addListener(sparkScanDelegate)
        print("SparkScan delegate added.")
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Stuff here")
                ScannedItemsList(items: $sparkScanDelegate.scannedItems)
                SparkScanRepresentableView(context: context, sparkScan: sparkScan)
                    .onAppear {
                        // Start scanning when the view appears
                        sparkScanDelegate.startScanning
                    }
                    .onDisappear {
                        // Stop scanning when the view disappears
                        sparkScanDelegate.stopScanning
                    }
            }
            
            //   .frame(height: 300)
        }
    }
}



class SparkScanDelegate: NSObject, SparkScanListener, ObservableObject {
    @Published var scannedItems: [String] = []
    
    override init() {
        print("starting..")
    }
    
    func sparkScan(_ sparkScan: SparkScan, didScanIn session: SparkScanSession, frameData: FrameData?) {
        if let barcode = session.newlyRecognizedBarcodes.first?.data {
            DispatchQueue.main.async {
                print("Scanned barcode: \(barcode)") // <-- Add this print statement
                self.scannedItems.append(barcode)
            }
        } else {
            print("Delegate method called, but no barcode data found.") // <-- Add this print statement
        }
    }
    

}


extension SparkScanRepresentableView {
    func startScanning() {
        // Assuming sparkScanView is a stored property in SparkScanRepresentableView
        sparkScanView.prepareScanning()
    }
    
    func stopScanning() {
        sparkScanView.stopScanning()
    }
}
