//
//  DappCardProtocol.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 09/07/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal protocol DappCardProtocol {
    
    var token: String! { get }
     
    var cardholder: String! { get }
    
    var lastFour: String! { get }
    
    var brand: String! { get }
    
    init(with data: [String: Any])
    
    static func add(_ cardNumber: String, cardholder: String, cvv: String, expMonth: String, expYear: String, email: String, phoneNumber: String, onCompletion: @escaping (DappCard?, DappError?) -> ())
}

internal extension DappCardProtocol {
    
    static func validateCardData(_ cardNumber: String, cardholder: String, cvv: String, expMonth: String, expYear: String, email: String, phoneNumber: String) -> DappError? {
        if cardNumber.count < 13 || cardNumber.count > 19 {
            return .invalidCardNumber
        }
        
        if cardholder.isEmpty || cardholder.count > 214 {
            return .invalidCardholder
        }
        
        if !NSPredicate(format: "SELF MATCHES %@", "[0-9]{3,4}").evaluate(with: cvv) {
            return .invalidCVV
        }
        
        guard let month = Int(expMonth), month < 13 && month > 0 else {
            return .invalidExpiringMonth
        }
        
        guard let year = Int(expYear) else {
            return .invalidExpiringYear
        }
        
        if phoneNumber.count != 10 {
            return .invalidPhoneNumber
        }
        
        if !validateEmail(email) || email.count > 214 {
            return .invalidMail
        }
        
        let cal = Calendar.current
        let date = Date()
        let curYear = cal.component(.year, from: date)
        let curMonth = cal.component(.month, from: date)
        if year < curYear || (year == curYear && month < curMonth) {
            return .cardExpired
        }
        
        return nil
    }
    
    static func validateEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
