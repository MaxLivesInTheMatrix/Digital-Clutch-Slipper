//
//  ViewController.swift
//  ClutchSlipperSB
//
//  Created by Max Sorin on 7/24/23.
//

import UIKit
import CoreBluetooth


final class ViewController: UIViewController, BluetoothSerialDelegate {
    
    @IBOutlet weak var InitialDelayLabel: UILabel!
    @IBOutlet weak var InitialClutchDelay: UITextField!
    @IBOutlet weak var ClutchHoldLabel: UILabel!
    @IBOutlet weak var ClutchHoldTime: UITextField!
    @IBOutlet weak var OutputWindow: UITextView!
    @IBOutlet weak var ConnectDevice: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitialClutchDelay.delegate = self
        ClutchHoldTime.delegate = self
        // Do any additional setup after loading the view.
        // init serial
        serial = BluetoothSerial(delegate: self)
        reloadView()
    }
    
    @IBAction func ENABLELAUNCH(_ sender: Any) {
        
        OutputWindow.text = "Initial Delay: \(InitialClutchDelay.text!)\nClutch Hold: \(ClutchHoldTime.text!)"
        
        
        // Fade in to red color over 1 second
        UIView.animate(withDuration: 1.0, animations: {
            self.view.backgroundColor = UIColor.red
        }) { (finished) in
            // After the fade-in animation completes, wait for 15 seconds and then initiate fade-out
            DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                UIView.animate(withDuration: 1.0, animations: {
                    self.view.backgroundColor = UIColor.white 
                })
            }
        }
        
        // send the message to the bluetooth device
        var msg = "<1,\(InitialClutchDelay.text!), \(ClutchHoldTime.text!) >"
        
        // send the message and clear the textfield
        serial.sendMessageToDevice(msg)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        InitialClutchDelay.resignFirstResponder()
        ClutchHoldTime.resignFirstResponder()
    }
    @objc func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
            //navItem.title = serial.connectedPeripheral!.name
            ConnectDevice.setTitle("Disconnect", for: .normal)
            ConnectDevice.tintColor = UIColor.red
            ConnectDevice.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            ConnectDevice.setTitle("Connect Device", for: .normal)
            ConnectDevice.tintColor = view.tintColor
            ConnectDevice.isEnabled = true
        } else {
            ConnectDevice.setTitle("Connect Device", for: .normal)
            ConnectDevice.tintColor = view.tintColor
            ConnectDevice.isEnabled = false
        }
    }
    
    @IBAction func ConnectDevicePressed(_ sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
}

extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: BluetoothSerialDelegate
        
//        func serialDidReceiveString(_ message: String) {
//          //   add the received text to the textView, optionally with a line break at the end
//            mainTextView.text! += message
//            let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
//            if pref == ReceivedMessageOption.newline.rawValue { mainTextView.text! += "\n" }
//            textViewScrollToBottom()
//        }
        
        func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
            reloadView()
           // dismissKeyboard()
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Disconnected"
            hud?.hide(true, afterDelay: 1.0)
        }
        
        func serialDidChangeState() {
            reloadView()
            if serial.centralManager.state != .poweredOn {
                let hud = MBProgressHUD.showAdded(to: view, animated: true)
                hud?.mode = MBProgressHUDMode.text
                hud?.labelText = "Bluetooth turned off"
                hud?.hide(true, afterDelay: 1.0)
            }
        }
}
