//
//  DappWallet.swift
//  DappVendor
//
//  Created by Rodrigo Rivas on 22/02/21.
//  Copyright © 2021 Dapp. All rights reserved.
//

import Foundation

public class DappWallet {
    
    internal var id: String
    
    internal var qrSource: Int
    
    public var name: String
    
    public var pushNotifications: Bool
        
    internal init(id: String, name: String, qrSource: Int, pushNotifications: Bool) {
        self.id = id
        self.name = name
        self.qrSource = qrSource
        self.pushNotifications = pushNotifications
    }
    
}
