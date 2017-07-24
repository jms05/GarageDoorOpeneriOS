//
//  GarageDoor.swift
//  Garage Door Opener
//
//  Created by Joao Silva on 7/24/17.
//  Copyright © 2017 Joao Silva. All rights reserved.
//

import UIKit
import Foundation

class GarageDoor: NSObject {
    var connected = false
    var host : String?
    var port = -1
    var client : TCPClient?
    
    init(port : Int, host : String ){
        self.port = port
        self.host = host
        self.connected = false
        self.client = nil
    }
    
    public func connect() -> Bool{
        self.client = TCPClient(address: self.host!, port: Int32(self.port))
        self.connected = self.client!.connect(timeout: 3)
        return self.connected
    }
    
    public func checkConnected() -> Bool{
        return self.connected
    }
    
    
    private func requestKey() -> String{
        var tempKey = "-1"
        let keyQuerry = "CODE?"
        let querrySent = self.writeToSocket(data : keyQuerry)
        if(querrySent==true){
            tempKey = self.readFromSocket(from : self.client!)!
        }else{
            self.disconnect()
        }
        return tempKey
    }
    
    public func checkStatus() -> Int?{
        var ret : Int?
        ret = -20
        let statusQuerry = "STATUS?"
        let querrySent = self.writeToSocket(data : statusQuerry)
        if(querrySent==true){
            let resposta = self.readFromSocket(from : self.client!)!
            ret = Int(resposta)
        }else{
            self.disconnect()
        }
        return ret
    }
    
    private func sendClick(key : String) -> Int{
        var ret : Int = -2
        let querry = "CLICK?\(key)"
        let querrySent = self.writeToSocket(data : querry)
        if(querrySent==true){
            let resposta = self.readFromSocket(from : self.client!)
            if(resposta != nil){
                ret = Int(resposta!)!
            }
            
        }else{
            ret = -2
            self.disconnect()
        }
        return ret
    }
    
    public func openDoor() -> Int{
        let key = self.requestKey()
        if(key == "-1"){
            return -3
        }else{
            return self.sendClick(key: key)
        }
    }
    
    
    public func endComunication() -> Bool{
        let endQuerry = "FIM?"
        let querrySent = self.writeToSocket(data: endQuerry)
        if (querrySent==false){
            self.disconnect()
        }else{
            //_ = readFromSocket(from: self.client!)
            self.disconnect()
        }
        return true
    }
    
    
    public func disconnect(){
        self.client?.close()
        self.client=nil
        self.connected=false
    }
    
    
   
    
    private func readFromSocket(from client: TCPClient) -> String? {
        //sleep(1)
        
        var response = client.read(1024*10)
        //print(response)
        while (response==nil){
            response = client.read(1024*10)
            //print(response)
        }
        
        let s =  String(bytes: response!, encoding: .utf8)!
        //print("Resposta: \(s)")
        return s
    }

    
    private func writeToSocket(data : String) -> Bool {
        print("SENT: \(data)")
        let sent  = client?.send(data: [UInt8](data.utf8))
        return sent!
    }

}

