//
//  DappError.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

public enum DappError: Error {
    //MARK: - Core
    case error(Error)
    case keyIsNotSet
    case responseError(message: String?)
    case userCancelled //se usa a la hora de intentar mandar un pago de vendor a wallet y si un usuario cierra el scanner
    
    //MARK: - Scanner
    case cameraNotAllowed
    
    //MARK: - Card
    case cardExpired
    case invalidCardholder
    case invalidCardNumber
    case invalidExpiringMonth
    case invalidExpiringYear
    case invalidCVV
    case invalidMail
    case invalidPhoneNumber
    
    //MARK: - DappRPCode
    case deleteDappRPCodeFailed //vendor
    case renewDappRPCodeFailed //vendor
    
    //MARK: - DappPOSCode
    case noWalletAvailable //customer
    case invalidURLScheme //customer
    case invalidDappPOSCode //wallet
    case pushNotificationInvalidCode
    
    public var localizedDescription: String {
        switch self {
        //core
        case .error(let error):
            return error.localizedDescription
        case .keyIsNotSet:
            return "DappError: Public Key is not set."
        case .responseError(let msg):
            if let m = msg {
                return "DappError: \(m)"
            }
            return "DappError: An error has occurred processing the server response."
        case .userCancelled:
            return "DappError: User cancelled payment."
            
        //scanner
        case .cameraNotAllowed:
            return "DappError: User did not give permission to use the camera."
            
        //card
        case .cardExpired:
            return "DappError: Card expired."
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
            return "DappError: Invalid phone number. Length must be 10 digits."
            
        //dappRPCode
        case .deleteDappRPCodeFailed:
            return "DappError: Request to delete DappRPCode failed."
        case .renewDappRPCodeFailed:
            return "DappError: Request to renew DappRPCode failed."
            
        //dappPOSCode
        case .noWalletAvailable:
            return "DappError: No wallet compatible with Dapp is installed in the device."
        case .invalidURLScheme:
            return "DappError: App has not configured URLSchemes correctly on info.plist."
        case .invalidDappPOSCode:
            return "DappError: QR is not a valid DappPOSCode."
        case .pushNotificationInvalidCode:
            return "DappError: Code must be created before sending push notification"
        }
    }
}
