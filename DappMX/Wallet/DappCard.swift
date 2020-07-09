//
//  DappCard.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/26/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

public class DappCard: DappCardProtocol {
    
    public var token: String!
    
    public var cardholder: String!
    
    public var lastFour: String!
    
    public var brand: String!
    
    required internal init(with data: [String: Any]) {
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
    
    public static func add(_ cardNumber: String, cardholder: String, cvv: String, expMonth: String, expYear: String, email: String, phoneNumber: String, onCompletion: @escaping (DappCard?, DappError?) -> ()) {
        if let e = DappCard.validateCardData(cardNumber, cardholder: cardholder, cvv: cvv, expMonth: expMonth, expYear: expYear, email: email, phoneNumber: phoneNumber) {
            onCompletion(nil, e)
            return
        }
        let year2digits = String(expYear.suffix(2))
        DappApiWallet.card(DappEncryption.encrypt(cardNumber), cardholder: DappEncryption.encrypt(cardholder), cvv: DappEncryption.encrypt(cvv), expMonth: DappEncryption.encrypt(expMonth), expYear: DappEncryption.encrypt(year2digits), email: DappEncryption.encrypt(email), phoneNumber: DappEncryption.encrypt(phoneNumber)) { (data, error) in
            if let e = error {
                onCompletion(nil, e)
                return
            }
            guard let d = data else {
                onCompletion(nil, .responseError(message: nil))
                return
            }
            onCompletion(DappCard(with: d), nil)
        }
    }
    
}

