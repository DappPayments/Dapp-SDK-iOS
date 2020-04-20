//
//  BaseDappApi.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal protocol DappApiProtocol {
    
    static var authHeader: String { get }
    
    static var httpURL: String { get }
    
    static var socketURL: String { get }

}

internal extension DappApiProtocol {
    
    static func httpRequest(path: String, parameters: [String: Any]? = nil, method: String? = nil, defaultRc: Bool = true, onCompletion: @escaping DappHttpResponse) {
        if Dapp.shared.apiKey.isEmpty {
            onCompletion(nil, .keyIsNotSet)
            return
        }
        DappHttpClient.request(url: httpURL + path, authHeader: authHeader, params: parameters?.query(), method: method, defaultRc: defaultRc, onCompletion: onCompletion)
    }
}

internal protocol DappPOSApiProtocol: DappApiProtocol { }

internal extension DappPOSApiProtocol {
    
    static var authHeader: String {
        return ":" + Dapp.shared.apiKey
    }
    
    static var httpURL: String {
        switch Dapp.shared.enviroment {
        case .sandbox:
            return "https://sandbox.dapp.mx/v1/"
        case .production:
            return "https://api.dapp.mx/v1/"
        }
    }
    
    static var socketURL: String {
        return ""
    }
    
    static func dappCode(amount: Double, description: String, reference: String?, onCompletion: @escaping DappHttpResponse) {
        var paramsDic: [String: Any] = ["amount": amount,
                                        "description": description]
        if let r = reference {
            paramsDic["reference"] = r
        }
        httpRequest(path: "dapp-codes/", parameters: paramsDic, onCompletion: onCompletion)
    }
}
