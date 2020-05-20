//
//  DappCode.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import UIKit

public enum DappQRType: Int {
    case dapp = 0
    case codi, codiDapp, unknown
}

public class DappPOSCode: DappCodeProtocol {
    
    public var dappId: String?
    public var amount: Double!
    public var description: String!
    public var reference: String?
    public var currency: String!
    public var user: DappUser?
    public var json = [String: Any]()
    
    private var qrString: String!
    private var callbackScheme: String?
    
    public init(_ code: String) {
        self.qrString = code
        guard let url = URL(string: code), let host = url.host, host == "dapp.mx" else {
            if let data = code.data(using: .utf8),
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let dappCode = json["dapp"] as? String {
                self.dappId = dappCode
            }
            return
        }
        
        var comps = url.pathComponents
        comps.removeFirst()
               
        guard let p = comps.first, p == "c" else {
            return
        }
        
        self.dappId = url.lastPathComponent
    }
    
    public init?(url: URL) {
        guard let host = url.host,
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let code = comps.queryItems?.first(where: {$0.name == "code"})?.value,
            let originScheme = comps.queryItems?.first(where: {$0.name == "origin"})?.value else {
                return nil
        }
        
        if host != "payment" {
            return nil
        }
        dappId = code
        callbackScheme = originScheme
    }
    
    public func read(onCompletion: @escaping (DappError?) -> ()) {
        if getQRType() == .codi {
            onCompletion(.invalidDappPOSCode)
            return
        }
        
        var code: String
        if isValidDappCode(), let id = dappId {
            code = "https://dapp.mx/c/\(id)"
        }
        else {
            code = qrString
        }
        
        DappApiWallet.dappCode(code.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!) { [weak self] (data, error) in
            guard let code = self else {
                return
            }
            if let e = error {
                onCompletion(e)
                return
            }
            guard let d = data else {
                onCompletion(.responseError(message: nil))
                return
            }
            if let currency = d["currency"] as? String {
                code.currency = currency
            }
            if let description = d["description"] as? String {
                code.description = description
            }
            if let amount = d["amount"] as? Double {
                code.amount = amount
            }
            if let userData = d["dapp_user"] as? [String: Any] {
                code.user = DappUser(with: userData)
            }
            code.json = d
            onCompletion(nil)
        }
    }
       
    public func returnPayment(paymentId: String) {
        guard let scheme = callbackScheme else {
            return
        }
        UIApplication.shared.open(URL(string: "\(scheme)://payment?id=\(paymentId)")!)
    }
    
    public func isCoDi() -> Bool {
        let qrType = getQRType()
        return qrType == .codi || qrType == .codiDapp
    }
    
    public func getQRType() -> DappQRType {
        if let data = qrString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let jsonV = json["v"] as? [String: Any], let jsonIc = json["ic"] as? [String: Any] {
                if json["TYP"] != nil && json["CRY"] != nil && jsonV["DEV"] != nil && jsonIc["IDC"] != nil && jsonIc["SER"] != nil && jsonIc["ENC"] != nil {
                    if json["dapp"] != nil {
                        return .codiDapp
                    }
                    return .codi
                }
            }
            else if json["dapp"] != nil {
                return .dapp
            }
        }
        
        if let url = URL(string: qrString), let host = url.host, host == "dapp.mx" {
            var comps = url.pathComponents
            comps.removeFirst()
            if let p = comps.first, p == "c" {
                return .dapp
            }
        }
        
        return .unknown
    }
    
    public func isValidDappCode() -> Bool {
        let qrType = getQRType()
        return qrType == .dapp || qrType == .codiDapp
    }
    
}
