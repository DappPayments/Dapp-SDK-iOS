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
    
    public var name: String
        
    internal init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
}
