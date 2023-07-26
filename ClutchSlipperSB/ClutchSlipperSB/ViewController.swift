//
//  ViewController.swift
//  ClutchSlipperSB
//
//  Created by Max Sorin on 7/24/23.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var InitialDelayLabel: UILabel!
    @IBOutlet weak var InitialClutchDelay: UITextField!
    @IBOutlet weak var ClutchHoldLabel: UILabel!
    @IBOutlet weak var ClutchHoldTime: UITextField!
    @IBOutlet weak var OutputWindow: UITextView!
    
    // Declare the variable to store the state for arduino
    var launchEnabled = false
    
    
    // Add the central manager and the Arduino peripheral
    var centralManager: CBCentralManager!
    var arduinoPeripheral: CBPeripheral?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitialClutchDelay.delegate = self
        ClutchHoldTime.delegate = self
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    @IBAction func ENABLELAUNCH(_ sender: Any) {
        launchEnabled = true
        OutputWindow.text = "Initial Delay: \(InitialClutchDelay.text!)\nClutch Hold: \(ClutchHoldTime.text!)\nLaunch Enabled? \(launchEnabled)"
        sendSignalToArduino()


        // Fade in to red color over 1 second
        UIView.animate(withDuration: 1.0, animations: {
            self.view.backgroundColor = UIColor.red
        }) { (finished) in
            // After the fade-in animation completes, wait for 10 seconds and then initiate fade-out
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.launchEnabled = false
                self.sendSignalToArduino()
                self.OutputWindow.text = "Initial Delay: \(self.InitialClutchDelay.text!)\nClutch Hold: \(self.ClutchHoldTime.text!)\nLaunch Enabled? \(self.launchEnabled)"
                UIView.animate(withDuration: 1.0, animations: {
                    self.view.backgroundColor = UIColor.white
                })
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        InitialClutchDelay.resignFirstResponder()
        ClutchHoldTime.resignFirstResponder()
    }
}

extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: CBCentralManagerDelegate {
    //Implement central manager delegate methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Check if Bluetooth is powered on
        if central.state == .poweredOn {
            // Start scanning for peripherals with the Arduino's service UUID
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check if the discovered peripheral is your Arduino
        if peripheral.name == "Arduino_Name" {
            // Save a reference to the Arduino peripheral
            arduinoPeripheral = peripheral
            
            // Connect to the Arduino peripheral
            centralManager.connect(arduinoPeripheral!, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Once connected,send the high/low signal to the Arduino
        sendSignalToArduino()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle the failure to connect
    }
    
    // Implement a function to send the signal (high or low) to the Arduino
    func sendSignalToArduino() {
        guard let arduinoPeripheral = arduinoPeripheral else {
            return
        }
        
        // Prepare your signal data (1 for high, 0 for low)
        let signalData = Data([launchEnabled ? 0x01 : 0x00])

        // Send the signal to the Arduino
        // Replace ARDUINO_CHARACTERISTIC_UUID with the characteristic UUID for writing the signal
        if let characteristic = arduinoPeripheral.services?.first?.characteristics?.first(where: { $0.uuid == nil }) {
            arduinoPeripheral.writeValue(signalData, for: characteristic, type: .withResponse)
        }
    }

}
