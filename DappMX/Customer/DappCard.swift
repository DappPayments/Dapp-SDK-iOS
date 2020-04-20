//
//  DappCard.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/26/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

public struct DappCard {
    
    public var token: String!
    
    public var cardholder: String!
    
    public var lastFour: String!
    
    public var brand: String!
    
    internal init(with data: [String: Any]) {
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
        if cardNumber.count < 13 || cardNumber.count > 19 {
            onCompletion(nil, .invalidCardNumber)
            return
        }
        
        if cardholder.isEmpty || cardholder.count > 214 {
            onCompletion(nil, .invalidCardholder)
            return
        }
        
        if !NSPredicate(format: "SELF MATCHES %@", "[0-9]{3,4}").evaluate(with: cvv) {
            onCompletion(nil, .invalidCVV)
            return
        }
        
        guard let month = Int(expMonth), month < 13 && month > 0 else {
            onCompletion(nil, .invalidExpiringMonth)
            return
        }
        
        guard let year = Int(expYear) else {
            onCompletion(nil, .invalidExpiringYear)
            return
        }
        
        if phoneNumber.count != 10 {
            onCompletion(nil, .invalidPhoneNumber)
            return
        }
        
        if !validateEmail(email) || email.count > 214 {
            onCompletion(nil, .invalidMail)
            return
        }
        
        let cal = Calendar.current
        let date = Date()
        let curYear = cal.component(.year, from: date)
        let curMonth = cal.component(.month, from: date)
        if year < curYear || (year == curYear && month < curMonth) {
            onCompletion(nil, .cardExpired)
            return
        }
        let year2digits = String(expYear.suffix(2))
        
        DappApiCustomer.card(DappEncryption.encrypt(cardNumber), cardholder: DappEncryption.encrypt(cardholder), cvv: DappEncryption.encrypt(cvv), expMonth: DappEncryption.encrypt(expMonth), expYear: DappEncryption.encrypt(year2digits), email: DappEncryption.encrypt(email), phoneNumber: DappEncryption.encrypt(phoneNumber)) { (data, error) in
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
    
    private static func validateEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

