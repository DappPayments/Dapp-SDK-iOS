//
//  DappApi.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal class DappApiWallet: DappApiProtocol {
    
    static var authHeader: String {
        return Dapp.shared.apiKey + ":"
    }
    
    static var httpURL: String {
        switch Dapp.shared.enviroment {
        case .production:
            return "https://wallets.dapp.mx/v1/"
        case .sandbox:
            return "https://wallets-sandbox.dapp.mx/v1/"
        }
    }
    
    static var socketURL: String {
        switch Dapp.shared.enviroment {
        case .production:
            return "wss://dapp.mx/sockets/"
        case .sandbox:
            return "wss://sandbox.dapp.mx/sockets/"
        }
    }
    
    static func dappCode(_ code: String, onCompletion: @escaping DappHttpResponse) {
        //DappHttpClient.request(url: httpURL + "dapp-codes/\(code)", authHeader: authHeader, onCompletion: onCompletion)
        httpRequest(path: "dapp-codes/\(code)", onCompletion: onCompletion)
    }
    
    static func paymentCodeStatus(_ code: String, onCompletion: @escaping DappHttpResponse) {
        httpRequest(path: "payments/code/\(code)/status/", onCompletion: onCompletion)
    }
    
    static func renewPaymentCode(_ code: String, onCompletion: @escaping DappHttpResponse) {
        httpRequest(path: "payments/code/\(code)/", method: "PUT", onCompletion: onCompletion)
    }
    
    static func deletePaymentCode(_ code: String, onCompletion: @escaping DappHttpResponse) {
        httpRequest(path: "payments/code/\(code)/", method: "DELETE", onCompletion: onCompletion)
    }
    
    static func paymentCodeSocket(_ code: String) -> DappWSClient {
        return DappWSClient(url: socketURL + "payments/code/\(code)", header: authHeader)
    }
    
}
