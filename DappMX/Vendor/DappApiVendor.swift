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
    
    static func getPayments(_ startDate: Date, endDate: Date, onCompletion: @escaping DappHttpResponse) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        httpRequest(path: "payments?start_date=\(dateFormatter.string(from: startDate))&end_date=\(dateFormatter.string(from: endDate))", method: "GET", defaultRc: false, onCompletion: onCompletion)
    }
    
    static func paymentCode(_ code: String, amount: Double, description: String, reference: String?, onCompletion: @escaping DappHttpResponse) {
        var paramsDic: [String: Any] = ["amount": amount,
                                        "description": description]
        if let r = reference {
            paramsDic["reference"] = r
        }
        httpRequest(path: "payments/code/\(code.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)", parameters: paramsDic, onCompletion: onCompletion)
    }
    
    static func dappCodeCodiPush(_ code: String, phone: String, onCompletion: @escaping DappHttpResponse) {
        let params = ["phone": phone]
        httpRequest(path: "dapp-codes/\(code)/codi/push/", parameters: params, defaultRc: false, onCompletion: onCompletion)
    }
    
    static func dappCodePush(_ code: String, phone: String, destination: String, onCompletion: @escaping DappHttpResponse) {
        let params = ["phone": phone,
                      "destination": destination]
        httpRequest(path: "dapp-codes/\(code)/push/", parameters: params, defaultRc: false, onCompletion: onCompletion)
    }
    
    static func dappCodePushDestinations(_ onCompletion: @escaping DappHttpResponse) {
        httpRequest(path: "dapp-codes/push/destinations/", defaultRc: false, onCompletion: onCompletion)
    }
    
    static func dappCodePayment(_ code: String, onCompletion: @escaping DappHttpResponse) {
        httpRequest(path: "dapp-codes/\(code)/payment/", onCompletion: onCompletion)
    }
    
    static func dappCodeSocket(_ code: String) -> DappWSClient {
        return DappWSClient(url: socketURL + "dapp-code/\(code)")
    }
    
    static func dappCodeWallets(onCompletion: @escaping DappHttpResponse) {
        httpRequest(path: "dapp-codes/wallets/", method: "GET", defaultRc: false, onCompletion: onCompletion)
    }
}
