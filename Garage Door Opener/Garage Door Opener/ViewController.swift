//
//  ViewController.swift
//  Garage Door Opener
//
//  Created by Joao Silva on 7/23/17.
//  Copyright © 2017 Joao Silva. All rights reserved.
//

import UIKit
//import SwiftSocket

class ViewController: UIViewController, UITextFieldDelegate{
   
    var connected = false

    var cordefault=UIColor.gray
    var app : GarageDoor?
    @IBOutlet weak var portSteperValue: UIStepper!
    @IBOutlet weak var portLabelValue: UILabel!
    @IBOutlet weak var hostLabelValue: UITextField!
    @IBOutlet weak var statusDoorLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hostLabelValue.delegate = self
        
    
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    @IBAction func stepperChancheAction(steper: UIStepper){
        portLabelValue.text=String(Int(portSteperValue.value))
    }
    
    @IBAction func connectServer(button :UIButton){
        
        if(connected==false){
            app = GarageDoor(port: Int(portSteperValue.value), host: hostLabelValue.text!)

        
            if(true != app?.connect()) {
                    let host = hostLabelValue.text!
                    let port = String(Int(portSteperValue.value))
                    let second = "\(host):\(port)"
                    let alert = UIAlertController(title: "ERROR", message: "CONENCTING to "+second , preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
            }
            connected = (app?.checkConnected())!
            print("CONNECTED")
            checkStatus()
            if(connected==true){
                connectButton.setTitle("Disconnect", for: .normal)
            }
        }else{
            _ = app?.endComunication()
            disconnect()
            
        }
    }

    @IBAction func checkStatus(button :UIButton){
        if connected{
            checkStatus()
        }
        else{
            let alert = UIAlertController(title: "Alert", message: "NOT CONNECTED", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func clickButton(button :UIButton){
        if connected{
            let result = app?.openDoor()
            if(-3 == result){
                disconnect()
                let alert = UIAlertController(title: "ERROR", message: "NO KEY RECIVED", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }else {
                if(result == 0){
                    let alert = UIAlertController(title: "Alert", message: "COMAND ACEPTED", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }else {
                    let alert = UIAlertController(title: "Alert", message: "COMAND NOT ACEPTED", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }

            }
   
        }else{
            let alert = UIAlertController(title: "Alert", message: "NOT CONNECTED", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    private func disconnect(){
        _ = app?.disconnect()
        connected = (app?.checkConnected())!
        connectButton.setTitle("Connect", for: .normal)
        statusDoorLabel.backgroundColor=cordefault
        statusDoorLabel.text=""
        
    }
    
    
    private func checkStatus(){
        var result = self.app?.checkStatus()
        if(result == nil){
            disconnect()
        }else{
            result = result!
            if (result == 1){
                statusDoorLabel.backgroundColor = UIColor.green
                statusDoorLabel.text="OPEN"
            }else{
                if(result == -1){
                    statusDoorLabel.backgroundColor = UIColor.red
                    statusDoorLabel.text="CLOSE"
                }else{
                    statusDoorLabel.backgroundColor = UIColor.yellow
                    statusDoorLabel.text="UNKNOWN"
                }
                
            }
        }
        
    }
    

    
    
    

}

