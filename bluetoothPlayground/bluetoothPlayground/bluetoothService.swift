////
////  bluetoothService.swift
////  bluetoothPlayground
////
////  Created by Max Sorin on 5/3/24.
////
//
//import Foundation
//import CoreBluetooth
//
//enum ConnectionStatus{
//    case connected
//    case disconnected
//    case scanning
//    case connecting
//    case error
//    
//}
//
//let clutchSlipperService: CBUUID = CBUUID(string: "A2E60B28-C215-0A78-B14B-3EE42DE1908B") // Let in swift are CONSTANTS
//// clutchSlippperCharacteristic: CBUUID = CBUUID(string: ) Idk the characteristics
//
//class BluetoothService: NSObject, ObservableObject {
//    private var centralManager: CBCentralManager!
//    
//    var clutchSlipperPeripheral: CBPeripheral?
//    @Published var peripheralStatus: ConnectionStatus = .disconnected
//    
//    override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//    
//    func scanForPeripherals() {
//        peripheralStatus = .scanning
//        centralManager.scanForPeripherals(withServices: [clutchSlipperService])
//    }
//}
//
//extension BluetoothService: CBCentralManagerDelegate {
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            scanForPeripherals()
//        }
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("Discovered \(peripheral.name ?? "Unknown")")
//        clutchSlipperPeripheral = peripheral
//        centralManager.connect(peripheral, options: nil) // Connect to the discovered peripheral
//        peripheralStatus = .connecting
//    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        peripheralStatus = .connected
//        print("Connected to \(peripheral.name ?? "Unknown")")
//        peripheral.delegate = self
//        peripheral.discoverServices([clutchSlipperService])
//        centralManager.stopScan()
//    }
//    
//
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) {
//        peripheralStatus = .disconnected
//    }
//    
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
//        peripheralStatus = .error
//        print(error?.localizedDescription ?? "No Error")
//    }
//}
//
//extension BluetoothService: CBPeripheralDelegate{
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
//        for service in peripheral.services ?? []{
//            if service.uuid == clutchSlipperPeripheral{
//                peripheral.discoverCharacteristics(nil, for: service) // Since idk any of the characteristics I put nil so it discovers it for me
//            }
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
//        for characteristic in service.characteristics ?? [] {
//            peripheral.setNotifyValue(true, for: characteristic)
//        }
//    }
//
//}
