import SwiftUI
import CoreBluetooth

class BluetoothViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    var connectedPeripheral: CBPeripheral?
    private var characteristic: CBCharacteristic? // Define the characteristic here

    func sendData(_ data: String) {
        guard let peripheral = connectedPeripheral else {
            print("No connected peripheral")
            return
        }

        guard let dataToSend = data.data(using: .ascii) else {
            print("Failed to encode ASCII string")
            return
        }

        guard let characteristic = self.characteristic else {
            print("Characteristic not set")
            return
        }

        peripheral.writeValue(dataToSend, for: characteristic, type: .withResponse)
    }
    
    func peripheral(at index: Int) -> CBPeripheral? {
        guard index >= 0 && index < peripherals.count else {
            return nil
        }
        return peripherals[index]
    }
    
    func connect(to index: Int) {
        guard index >= 0 && index < peripherals.count else {
            print("Invalid index")
            return
        }
        let peripheral = peripherals[index]
        centralManager?.connect(peripheral, options: nil)
    }

    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let peripheralName = peripheral.name {
            if !peripherals.contains(peripheral) {
                self.peripherals.append(peripheral)
                self.peripheralNames.append(peripheralName)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral)")
        connectedPeripheral = peripheral
        peripheral.delegate = self // Set delegate
        peripheral.discoverServices(nil) // Start service discovery
    }
}

extension BluetoothViewModel: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            print("No services found")
            return
        }
        
        for service in services {
            // Discover characteristics for each service
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("No characteristics found")
            return
        }
        
        for characteristic in characteristics {
            // Check for the characteristic properties you need, like writeable or notify
            if characteristic.properties.contains(.write) {
                // Found a characteristic that supports write operation
                self.characteristic = characteristic
                break
            }
        }
        
        if self.characteristic == nil {
            print("No characteristic found supporting write operation")
        }
    }
}

struct ContentView: View {
    @ObservedObject private var bluetoothViewModel = BluetoothViewModel()
    @State private var selectedPeripheralIndex: Int? = nil

    var body: some View {
        NavigationView {
            List(bluetoothViewModel.peripheralNames, id: \.self) { peripheralName in
                Button(action: {
                    if let index = bluetoothViewModel.peripheralNames.firstIndex(of: peripheralName) {
                        selectedPeripheralIndex = index
                        // Attempt to connect to the selected peripheral
                        bluetoothViewModel.connect(to: index)
                    }
                }) {
                    Text(peripheralName)
                }
            }
            .navigationTitle("Peripherals")
        }
        .onDisappear {
            // Disconnect from the connected peripheral when view disappears
            bluetoothViewModel.connectedPeripheral = nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
