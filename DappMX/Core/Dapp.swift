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
    
    public var apiKey = ""
    
    public var enviroment = DappEnviroment.production
    
    public static let shared = Dapp()
    
    public class func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        guard let host = url.host, host == "payment" else {
            return false
        }
        #if canImport(DappWallet)
        if getQueryStringParameter(from: url, param: "origin") != nil && getQueryStringParameter(from: url, param: "code") != nil {
            return true
        }
        #endif
        return false
    }
    
    private class func getQueryStringParameter(from url: URL, param: String) -> String? {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        return comps.queryItems?.first(where: { $0.name == param })?.value
    }
}
