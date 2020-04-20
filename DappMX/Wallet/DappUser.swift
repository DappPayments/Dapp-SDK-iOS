//
//  DappUser.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/31/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

public struct DappUser {
    
    public var name: String!
    
    public var address: String!
    
    public var image: URL?
    
    public var suggestTip: Bool!
    
    internal init(with data: [String: Any]) {
        if let name = data["name"] as? String {
            self.name = name
        }
        if let image = data["image"] as? String, let url = URL(string: image) {
            self.image = url
        }
        if let tip = data["suggest_tip"] as? Bool {
            self.suggestTip = tip
        }
        if let address = data["address"] as? String {
            self.address = address
        }
    }
}
