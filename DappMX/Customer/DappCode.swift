//
//  DappPOSCode.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/27/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import UIKit

public protocol DappCodeDelegate: AnyObject {
    func dappCode(_ code: DappCode, didSucceedWithPayment paymentId: String)
    func dappCode(_ code: DappCode, didFailWithError error: DappError)
}

public class DappCode: DappPOSCodeProtocol {
    
    public var dappId: String?
    public var amount: Double!
    public var description: String!
    public var reference: String?
    public weak var delegate: DappCodeDelegate?
    
    private weak var parentVC: UIViewController?
    private var schemeCallback: String?
    private static var walletsInstalled = [String]()
    private static var wallets = ["dappmxsantander": "Super Pago",
                                  "dappmxqrpago": "QR Pago"]
    private static var didDownloadWalletSchemes = false

    public required init(amount: Double, description: String, reference: String? = nil) {
        self.amount = amount
        self.description = description
        self.reference = reference
    }
    
    public init(dappId: String) {
        self.dappId = dappId
    }
    
    public func pay(from viewController: UIViewController) {
        guard let delegate = self.delegate else {
            print("Dapp: DappCodeDelegate is not set")
            return
        }
        if !DappCode.paymentsAvailable() {
            delegate.dappCode(self, didFailWithError: .noWalletAvailable)
            return
        }
        guard let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [Any],
            let first = types.first as? [String: Any], let schemes = first["CFBundleURLSchemes"] as? [String],
            let urlScheme = schemes.first else {
                delegate.dappCode(self, didFailWithError: .invalidURLScheme)
                return
        }
        schemeCallback = urlScheme
        parentVC = viewController
        if let code = dappId {
            selectWalletForPayment(code: code)
            return
        }
        create()
    }
    
    internal func create() {
        DappApiCustomer.dappCode(amount: amount, description: description, reference: reference) { (data, error) in
            if let e = error {
                self.delegate?.dappCode(self, didFailWithError: e)
                return
            }
            guard let shortCode = data?["short_code"] as? String else {
                self.delegate?.dappCode(self, didFailWithError: .responseError(message: nil))
                return
            }
            self.dappId = shortCode
            self.selectWalletForPayment(code: shortCode)
        }
    }
    
    public static func paymentsAvailable() -> Bool {
        guard let schemes = Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String] else {
            return false
        }
        let walletSchemes = schemes.filter({ wallets.index(forKey: $0) != nil })
        if walletSchemes.isEmpty {
            return false
        }
        walletsInstalled.removeAll()
        for s in walletSchemes {
            if UIApplication.shared.canOpenURL(URL(string: "\(s)://")!) {
                walletsInstalled.append(s)
            }
        }
        return !walletsInstalled.isEmpty
    }
    
    private func selectWalletForPayment(code: String) {
        if DappCode.walletsInstalled.count == 1, let scheme = DappCode.walletsInstalled.first {
            self.goToPayment(scheme: scheme, code: code)
            return
        }
        let alert = UIAlertController(title: "Pagar", message: "Selecciona el wallet con el que deseas pagar", preferredStyle: .actionSheet)
        for w in DappCode.walletsInstalled {
            let action = UIAlertAction(title: DappCode.wallets[w], style: .default) { (_) in
                self.goToPayment(scheme: w, code: code)
            }
            alert.addAction(action)
        }
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel) { (_) in
            self.delegate?.dappCode(self, didFailWithError: .userCancelled)
        }
        alert.addAction(cancel)
        self.parentVC?.present(alert, animated: true)
    }
    
    private func goToPayment(scheme: String, code: String) {
        let url = URL(string: "\(scheme)://payment?code=\(code)&origin=\(schemeCallback!)")!
        UIApplication.shared.open(url) { [weak self]  (success) in
            guard let code = self else {
                return
            }
            if success {
                NotificationCenter.default.addObserver(code, selector: #selector(code.paymentCallback(_:)), name: Dapp.paymentNotification, object: nil)
            }
        }
    }
    
    @objc private func paymentCallback(_ notification: NSNotification) {
        if let paymentId = notification.userInfo?["paymentId"] as? String {
            delegate?.dappCode(self, didSucceedWithPayment: paymentId)
        }
    }
    
    internal static func getWalletSchemes() {
        if didDownloadWalletSchemes {
            return
        }
        DappApiCustomer.walletSchemes { (data, error) in
            guard let json = data, let rc = json["rc"] as? Int, rc == 0, let schemesArray = json["data"] as? [[String: String]] else {
                return
            }
            
            var walletSchemes = [String: String]()
            for json in schemesArray {
                if let name = json["name"], let scheme = json["scheme"] {
                    walletSchemes[scheme] = name
                }
            }
            wallets = walletSchemes
            didDownloadWalletSchemes = true
        }
    }
    
}
