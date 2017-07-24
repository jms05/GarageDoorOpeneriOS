//
//  TcpClient.swift
//  Garage Door Opener
//
//  Created by Joao Silva on 7/23/17.
//  Copyright © 2017 Joao Silva. All rights reserved.
//

import UIKit

class TcpClient: NSObject {
    var host
    var port
    var socket
    
    func setup(){
        socket = TCPClient(address: host, port:port)
        switch client.connect(timeout: 10) {
            case .success:
                // Connection successful
            case .failure(let error):
                // 
        }
    }
    
}
