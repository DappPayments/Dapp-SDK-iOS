//
//  DappApi.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/26/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal class DappApiCustomer: DappPOSApiProtocol {
    
    static func card(_ number: String, cardholder: String, cvv: String, expMonth: String, expYear: String, email: String, phoneNumber: String, onCompletion: @escaping DappHttpResponse) {
        
        let paramsDic = ["card_number": number,
                         "cardholder": cardholder,
                         "cvv": cvv,
                         "exp_month": expMonth,
                         "exp_year": expYear,
                         "email": email,
                         "phone_number": phoneNumber]
        httpRequest(path: "cards/", parameters: paramsDic, onCompletion: onCompletion)
    }
    
    static func walletSchemes(_ onCompletion: @escaping DappHttpResponse) {
        httpRequest(path: "wallets/schemes/ios", defaultRc: false, onCompletion: onCompletion)
    }
}
