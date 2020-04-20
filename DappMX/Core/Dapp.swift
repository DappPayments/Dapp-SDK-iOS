//
//  Dapp.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import UIKit

public enum DappEnviroment {
    case sandbox, production
}

public class Dapp {
    
    public var apiKey = "" {
        didSet {
            Dapp.didSetApiKey()
        }
    }
    
    public var enviroment = DappEnviroment.production {
        didSet {
            Dapp.didSetApiKey()
        }
    }
    
    public static let shared = Dapp()
    
    internal static let paymentNotification = NSNotification.Name("dappPayment")
    
    public class func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        guard let host = url.host, host == "payment" else {
            return false
        }
        #if canImport(DappCustomer)
        if let paymentId = getQueryStringParameter(from: url, param: "id") {
            NotificationCenter.default.post(name: Dapp.paymentNotification, object: nil, userInfo: ["paymentId": paymentId])
            return true
        }
        #endif
        #if canImport(DappWallet)
        if getQueryStringParameter(from: url, param: "origin") != nil && getQueryStringParameter(from: url, param: "code") != nil {
            return true
        }
        #endif
        return false
    }
    
    private static func didSetApiKey() {
        #if canImport(DappCustomer)
        DappCode.getWalletSchemes()
        #endif
    }
    
    private class func getQueryStringParameter(from url: URL, param: String) -> String? {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        return comps.queryItems?.first(where: { $0.name == param })?.value
    }
}
