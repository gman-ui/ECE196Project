//
//  WorkoutModel.swift
//  Workout Buddy
//
//  Created by Kavi Nelakonda on 11/8/22.
//

import Foundation
import SwiftUI
import CoreBluetooth



class WorkoutModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // CB objects
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    
    // UI interface variables
    @Published var connected: Bool = false
    @Published var loaded: Bool = false
    
    let SERVICE_UUID: CBUUID = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")

    var characteristics: [String: CBCharacteristic] = [:]

    let characteristic_key: [CBUUID: String] = [
        CBUUID(string: "57393a70-64a7-4d66-9892-9280a6b68bfd"): "x",
        CBUUID(string: "acde099b-8769-4d12-a924-4aef77cdcb5f"): "y",
        CBUUID(string: "411c9a4e-69e5-4b95-b3b1-5fae8b071514"): "z"
    ]
    
    // marking something as @Published will make it update in the views
    @Published var repCount: Int = 0
    @Published var wristLocation: Bool = true
    @Published var feedbackP: Bool = true
    var repQuality: Double = 1
    @Published var feedback: String = ""
    
    private var x: Double = 0
    private var y: Double = 0
    private var z: Double = 0
    
    @Published var exercise: String = "Chest Press"
    let exercises: [String] = ["Chest Press", "Squats", "Deadlifts", "Shoulder Press"]
    
    private let feedbackPos: [String] = ["Don't give up!",  "Almost there!", "Keep up the good work!", "You're great!", "Perfect!"]
    private let feedbackNeg: [String] = [ "Just cancel your gym membership, save some money" , "Are you even trying?", "C'mon, this is terrible", "That's.... sufficient I guess....", "Up to par, whatever....", "Booooooo"]
        
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func randomChoiceP() -> String{
        feedbackPos.randomElement()!
    }
    
    func randomChoiceN() -> String{
        feedbackNeg.randomElement()!
    }
    
    func increaseRep() -> Void{
        repCount += 1
    }
    
    func setExercise(e : String) -> Void{
        exercise = e
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
            startScanning()
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
            print("Error")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Discovered peripheral: \(peripheral)")
        
        self.peripheral = peripheral
        
        centralManager.connect(self.peripheral!)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        
        self.peripheral!.delegate = self
        self.peripheral!.discoverServices([SERVICE_UUID])
        
        stopScanning()
        
        // inform UI
        withAnimation {
            connected = true
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected.")
        
        self.peripheral = nil
        
        // inform UI
        withAnimation {
            connected = false
            loaded = false
        }
        startScanning()
    }
    
    
    func startScanning() {
        print("Scanning")
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID])
    }

    func stopScanning() {
        centralManager.stopScan()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        print("Discovering services...")
        
        for service in services {
            print("Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        print("Discovering characteristics for service: \(service)")
        
        for characteristic in characteristics {
            print("Characteristic: \(characteristic)")
            print("\t- R/W: \(characteristic.properties.contains(.read))/\(characteristic.properties.contains(.write))")
            
            if let name = characteristic_key[characteristic.uuid] {
                print("\t- Characteristic key: \(name)")
                self.characteristics[name] = characteristic

                self.peripheral?.readValue(for: characteristic)
            }
        }
        
        if characteristics.count == characteristic_key.count { // discovered all expected characteristics
            // inform UI
            withAnimation {
                loaded = true
            }
            
            // spawn daemon updater thread
            DispatchQueue.global().async {
                self.updatePeriodic()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            guard let data = characteristic.value else { return }
            
            switch characteristic_key[characteristic.uuid] {
            case "x":
                x = loadColor(data: data)
            case "y":
                y = loadColor(data: data)
            case "z":
                z = loadColor(data: data)
            default:
                print("Updated value for invalid characteristic.")
            }
            
            // inform UI to update to reflect computed property (color) change
            objectWillChange.send()
        }
    
    
    private func updatePeriodic() {
        while connected {
            Thread.sleep(forTimeInterval: 0.25)
            
            for (key, value) in zip(["x", "y", "z"], [x, y, z]) {
                guard let _ = peripheral else { return }
                peripheral?.writeValue(Data([UInt8(value * 255)]), for: characteristics[key]!, type: .withResponse)
            }
        }
    }
    
    private func loadColor(data: Data) -> Double {
        return Double(
            data.withUnsafeBytes({ (rawPtr: UnsafeRawBufferPointer) in
                return rawPtr.load(as: UInt8.self)
            })
        ) / 255.0
    }
}