//
//  DappCard.swift
//  Dapp SDK iOS
//
//  Created by Rodrigo Rivas Torres on 13/06/17.
//  Copyright © 2017 Dapp. All rights reserved.
//

import Foundation

public protocol DappCardDelegate {
    
    func dappCardFailure(error: DappError)
    
    func dappCardSuccess(card: DappCard)
}

public class DappCard {
    
    public var token: String!
    
    public var cardholder: String!
    
    public var lastFour: String!
    
    public var brand: String!
    
    public init(with data: [String: Any]) {
        if let token = data["id"] as? String {
            self.token = token
        }
        if let cardholder = data["cardholder"] as? String {
            self.cardholder = cardholder
        }
        if let lastFour = data["last_4"] as? String {
            self.lastFour = lastFour
        }
        if let brand = data["brand"] as? String {
            self.brand = brand
        }
    }
}
