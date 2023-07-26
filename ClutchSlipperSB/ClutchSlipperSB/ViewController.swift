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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitialClutchDelay.delegate = self
        ClutchHoldTime.delegate = self
        // Do any additional setup after loading the view.
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
                    self.view.backgroundColor = UIColor.white // Replace UIColor.white with your desired original background color
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
