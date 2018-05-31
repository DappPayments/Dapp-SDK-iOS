//
//  DappError.swift
//  Dapp SDK iOS
//
//  Created by Rodrigo Rivas Torres on 13/06/17.
//  Copyright © 2017 Dapp. All rights reserved.
//

import Foundation

public enum DappError: LocalizedError {
    
    case cardExpired
    case error(error: Error)
    case invalidCardholder
    case invalidCardNumber
    case invalidExpiringMonth
    case invalidExpiringYear
    case invalidCVV
    case invalidMail
    case invalidPhoneNumber
    case keyIsNotSet
    case merchantIdIsNotSet
    case responseError(msg: String?)
    case userCanceled
    
    public var errorDescription: String? {
        switch self {
        case .cardExpired:
            return "DappError: Card expired."
        case .error(let error):
            return error.localizedDescription
        case .invalidCardholder:
            return "DappError: Invalid cardholder."
        case .invalidCardNumber:
            return "DappError: Invalid card number."
        case .invalidExpiringMonth:
            return "DappError: Invalid expiration month."
        case .invalidExpiringYear:
            return "DappError: Invalid expiration year."
        case .invalidCVV:
            return "DappError: Invalid CVV."
        case .invalidMail:
            return "DappError: Invalid E-mail."
        case .invalidPhoneNumber:
            return "DappError: Invalid phone number. Length must be 10 digits"
        case .keyIsNotSet:
            return "DappError: Public Key is not set."
        case .merchantIdIsNotSet:
            return "DappError: Merchant ID is not set."
        case .responseError(let msg):
            if let m = msg {
                return "DappError: \(m)"
            }
            return "DappError: An error has occurred processing the server response."
        case .userCanceled:
            return "DappError: User cancelled payment"
        }
    }
}
