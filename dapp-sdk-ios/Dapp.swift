//
//  Dapp.swift
//  Dapp SDK iOS
//
//  Created by Rodrigo Rivas Torres on 02/06/17.
//  Copyright © 2017 Dapp. All rights reserved.
//

import UIKit

typealias ResponseHandler = (_ data: [String: Any]?, _ error: DappError?) -> ()

public enum DappEnviroment: Int {
    case production = 0
    case sandbox
    
    internal func getServer() -> String {
        switch self {
        case .production:
            return "https://api.dapp.mx/v1/"
        case .sandbox:
            return "https://sandbox.dapp.mx/v1/"
        }
    }
    
    internal func getPublicKey() -> String {
        switch self {
        case .production:
            if let filePath = Bundle(for: Dapp.self).path(forResource: "dapp_prod", ofType: "pem"), let contents = try? String(contentsOfFile: filePath) {
                var array = contents.components(separatedBy: "\n")
                array.removeLast()
                array.removeLast()
                array.removeFirst()
                return array.joined(separator: "")
            }
            return ""
        case .sandbox:
            if let filePath = Bundle(for: Dapp.self).path(forResource: "dapp_sandbox", ofType: "pem"), let contents = try? String(contentsOfFile: filePath) {
                var array = contents.components(separatedBy: "\n")
                array.removeLast()
                array.removeLast()
                array.removeFirst()
                return array.joined(separator: "")
            }
            return ""
        }
    }
    
    internal func getPublicKeyIdentifier() -> String {
        switch self {
        case .production:
            return "mx.dapp.sdk.publickey.production"
        case .sandbox:
            return "mx.dapp.sdk.publickey.sandbox"
        }
    }
}

public class Dapp {
    
    public var merchantId = ""
    
    public var apiKey = ""
    
    public var enviroment = DappEnviroment.production
    
    public var paymentDelegate: DappPaymentDelegate?
    
    public var cardDelegate: DappCardDelegate?
    
    public static let shared = Dapp()
    
    internal static let callbackNotification = NSNotification.Name("dappCallback")
    
    public class func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    public class func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        if sourceApplication != "mx.dapp" && sourceApplication != "mx.dapp.qa" {
            return false
        }
        
        var data = [String: Any]()
        data["id"] = getQueryStringParameter(from: url, param: "id")
        if let monto = getQueryStringParameter(from: url, param: "amount") {
            data["amount"] = Double(monto)
        }
        if let propina = getQueryStringParameter(from: url, param: "tip") {
            data["tip"] = Double(propina)
        }
        if let last4 = getQueryStringParameter(from: url, param: "last4") {
            data["last4"] = last4
        }
        data["currency"] = getQueryStringParameter(from: url, param: "currency")
        data["description"] = getQueryStringParameter(from: url, param: "description")
        data["reference"] = getQueryStringParameter(from: url, param: "reference")
        data["date"] = getQueryStringParameter(from: url, param: "date")
        data["client"] = getQueryStringParameter(from: url, param: "client")
        data["payment_type"] = getQueryStringParameter(from: url, param: "payment_type")
        
        NotificationCenter.default.post(name: Dapp.callbackNotification, object: nil)
        let payment = DappPayment(with: data)
        Dapp.shared.paymentDelegate?.dappPaymentSuccess(payment: payment)
        
        return true
    }
    
    public class func addCard(cardNumber: String, cardholder: String, cvv: String, expMonth: String, expYear: String, email: String, phoneNumber: String) {
        guard let delegate = Dapp.shared.cardDelegate else {
            print("Dapp: card delegate is not set")
            return
        }
        
        if Dapp.shared.merchantId.count == 0 {
            delegate.dappCardFailure(error: .merchantIdIsNotSet)
            return
        }
        
        if Dapp.shared.apiKey.count == 0 {
            delegate.dappCardFailure(error: .keyIsNotSet)
            return
        }
        
        if cardNumber.count < 13 {
            delegate.dappCardFailure(error: .invalidCardNumber)
            return
        }
        
        if cardholder.count == 0 {
            delegate.dappCardFailure(error: .invalidCardholder)
            return
        }
        
        if cvv.count != 3 && cvv.count != 4 && Int(cvv) != nil {
            delegate.dappCardFailure(error: .invalidCVV)
            return
        }
        
        guard let month = Int(expMonth), month < 13 && month > 0 else {
            delegate.dappCardFailure(error: .invalidExpiringMonth)
            return
        }
        
        guard let year = Int(expYear) else {
            delegate.dappCardFailure(error: .invalidExpiringYear)
            return
        }
        
        if phoneNumber.count != 10 {
            delegate.dappCardFailure(error: .invalidPhoneNumber)
            return
        }
        
        if !validateEmail(email) {
            delegate.dappCardFailure(error: .invalidMail)
            return
        }
        
        let cal = Calendar.current
        let curYear = cal.component(.year, from: Date())
        let curMonth = cal.component(.month, from: Date())
        if year < curYear || (year == curYear && month < curMonth) {
            delegate.dappCardFailure(error: .cardExpired)
            return
        }
        let year2digits = String(expYear.suffix(2))
        
        let params = "card_number=\(encrypt(string: cardNumber))&cardholder=\(encrypt(string: cardholder))&cvv=\(encrypt(string: cvv))&exp_month=\(encrypt(string: expMonth))&exp_year=\(encrypt(string: year2digits))&email=\(encrypt(string: email))&phone_number=\(encrypt(string: phoneNumber))"
        let handler: ResponseHandler = { data, error in
            if let e = error {
                delegate.dappCardFailure(error: e)
                return
            }
            
            delegate.dappCardSuccess(card: DappCard(with: data!))
        }
        dappRequest(url: "\(Dapp.shared.enviroment.getServer())cards/", params: params, handler: handler)
    }
    
    public class func isDappInstalled() -> Bool {
        guard let apps = Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String] else {
            return false
        }
        var dappIsQueryable = false
        for app in apps {
            if app == "dappmx" {
                dappIsQueryable = true
            }
        }
        if dappIsQueryable {
            return UIApplication.shared.canOpenURL(URL(string: "dappmx://payment")!)
        }
        print("Dapp: App has not configured LSApplicationQueriesSchemes correctly on info.plist.")
        return false
    }
    
    internal class func openAppStore() {
        UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/mx/app/dapp/id1271831127?mt=8")!)
    }
    
    public class func requestPayment(viewController: UIViewController, amount: Double, description: String, reference: String?) {
        if !isDappInstalled() {
            print("Dapp is not installed on the device.")
            openAppStore()
            return
        }
        guard let delegate = Dapp.shared.paymentDelegate else {
            print("Dapp: payment delegate is not set")
            return
        }
        
        if Dapp.shared.merchantId.count == 0 {
            delegate.dappPaymentFailure(error: .merchantIdIsNotSet)
            return
        }
        
        if Dapp.shared.apiKey.count == 0 {
            delegate.dappPaymentFailure(error: .keyIsNotSet)
            return
        }
        
        guard let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [Any],
            let first = types.first as? [String: Any], let schemes = first["CFBundleURLSchemes"] as? [String],
            let urlScheme = schemes.first else {
                print("Dapp: App has not configured URLSchemes correctly on info.plist.")
                openAppStore()
                return
        }
        
        let loadingViewController = DappLoadingViewController(nibName: "DappLoadingViewController", bundle: Bundle(for: DappLoadingViewController.self))
        loadingViewController.urlScheme = urlScheme
        loadingViewController.amount = amount
        loadingViewController.paymentDesc = description
        loadingViewController.reference = reference
        let nav = UINavigationController(rootViewController: loadingViewController)
        viewController.present(nav, animated: true, completion: nil)
    }
    
    internal class func dappRequest(url: String, params: String, handler: @escaping ResponseHandler) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
        let authData = "\(Dapp.shared.merchantId):\(Dapp.shared.apiKey)".data(using: String.Encoding.utf8)!
        let base64 = authData.base64EncodedString()
        request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let e = error {
                DispatchQueue.main.async {
                    handler(nil, DappError.error(error: e))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    handler(nil, DappError.responseError(msg: nil))
                }
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                DispatchQueue.main.async {
                    handler(nil, DappError.responseError(msg: nil))
                }
                return
            }
            
            guard let rc = json?["rc"] as? Int else {
                DispatchQueue.main.async {
                    handler(nil, DappError.responseError(msg: nil))
                }
                return
            }
            
            if rc != 0 {
                DispatchQueue.main.async {
                    handler(nil, DappError.responseError(msg: json?["msg"] as? String))
                }
                return
            }

            guard let jsonData = json?["data"] as? [String: Any] else {
                DispatchQueue.main.async {
                    handler(nil, DappError.responseError(msg: nil))
                }
                return
            }
            DispatchQueue.main.async {
                handler(jsonData, nil)
            }
        }
        task.resume()
    }
    
    internal class func encrypt(string: String) -> String {
        let key = Dapp.shared.enviroment.getPublicKey()
        let keyData = Data(base64Encoded: key)!
        let tag = Dapp.shared.enviroment.getPublicKeyIdentifier()
        let tagData = tag.data(using: .utf8)!
        
        let keyAddDict: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecValueData as String: keyData,
            kSecAttrApplicationTag as String: tagData,
            kSecReturnPersistentRef as String: true,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let addStatus = SecItemAdd(keyAddDict as CFDictionary, nil)
        guard addStatus == errSecSuccess || addStatus == errSecDuplicateItem else {
            return ""
        }
        
        let keyCopyDict: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: tagData,
            kSecReturnRef as String: true,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        var keyRef: AnyObject?
        let status = SecItemCopyMatching(keyCopyDict as CFDictionary, &keyRef)
        
        guard let unwrapperedKey = keyRef, status == errSecSuccess else {
            return ""
        }
        
        let blockSize = SecKeyGetBlockSize(unwrapperedKey as! SecKey)
        let maxChunkSize = blockSize - 11
        let dataMsg = string.data(using: .utf8)!
        
        var decryptedDataAsArray = [UInt8](repeating: 0, count: dataMsg.count)
        (dataMsg as NSData).getBytes(&decryptedDataAsArray, length: dataMsg.count)
        
        var encryptedDataBytes = [UInt8](repeating: 0, count: 0)
        var idx = 0
        while idx < decryptedDataAsArray.count {
            
            let idxEnd = min(idx + maxChunkSize, decryptedDataAsArray.count)
            let chunkData = [UInt8](decryptedDataAsArray[idx..<idxEnd])
            
            var encryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var encryptedDataLength = blockSize
            
            let status = SecKeyEncrypt(unwrapperedKey as! SecKey, .OAEP, chunkData, chunkData.count, &encryptedDataBuffer, &encryptedDataLength)
            
            guard status == noErr else {
                break
            }
            
            encryptedDataBytes += encryptedDataBuffer
            
            idx += maxChunkSize
        }
        
        let encryptedData = Data(bytes: UnsafePointer<UInt8>(encryptedDataBytes), count: encryptedDataBytes.count)
        
        return encryptedData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    }
    
    private class func getQueryStringParameter(from url: URL, param: String) -> String? {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        return comps.queryItems?.first(where: { $0.name == param })?.value
    }
    
    private class func validateEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
}
