//
//  DappApiVendor.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/30/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal class DappApiVendor: DappPOSApiProtocol {
    
    static var socketURL: String {
        switch Dapp.shared.enviroment {
        case .production:
            return "wss://dapp.mx/sockets/"
        case .sandbox:
            return "wss://sandbox.dapp.mx/sockets/"
        }
    }
    
    static func paymentCode(_ code: String, amount: Double, description: String, reference: String?, onCompletion: @escaping DappHttpResponse) {
        var paramsDic: [String: Any] = ["amount": amount,
                                        "description": description]
        if let r = reference {
            paramsDic["reference"] = r
        }
        httpRequest(path: "payments/code/\(code)", parameters: paramsDic, onCompletion: onCompletion)
    }
    
    static func dappCodeCodiPush(_ code: String, phone: String, onCompletion: @escaping DappHttpResponse) {
        let params = ["phone": phone]
        httpRequest(path: "dapp-codes/\(code)/codi/push/", parameters: params, defaultRc: false, onCompletion: onCompletion)
    }
    
    static func dappCodePayment(_ code: String, onCompletion: @escaping DappHttpResponse) {
        httpRequest(path: "dapp-codes/\(code)/payment/", onCompletion: onCompletion)
    }
    
    static func dappCodeSocket(_ code: String) -> DappWSClient {
        return DappWSClient(url: socketURL + "dapp-code/\(code)")
    }
}
