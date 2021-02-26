//
//  DappPOSCodeVendor.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/30/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import UIKit

public protocol DappPOSCodeDelegate: AnyObject {
    func dappCode(_ dappCode: DappPOSCode, didChangeStatus status: DappPOSCodeStatus)
}

public enum DappPOSCodeStatus {
    case created(String, UIImage?)
    case error(DappError)
    case payed(DappPayment)
}

public class DappPOSCode: DappPOSCodeProtocol, DappPOSCodeHelperDelegate {
    
    public var dappId: String?
    public var amount: Double!
    public var description: String!
    public var reference: String?
    public weak var delegate: DappPOSCodeDelegate?
    
    private var qrSize: CGSize?
    private var helper: DappPOSCodeHelper = DappPOSCodeHelper()
    
    public required init(amount: Double, description: String, reference: String? = nil) {
        self.amount = amount
        self.description = description
        self.reference = reference
    }
    
    public func createWithImage(size: CGSize) {
        qrSize = size
        create()
    }
    
    public func create() {
        if dappId != nil {
            print("Dapp: DappPOSCode has already been created before.")
            return
        }
        DappApiVendor.dappCode(amount: amount, description: description, reference: reference) { (data, error) in
            if let e = error {
                self.delegate?.dappCode(self, didChangeStatus: .error(e))
                return
            }
            guard let sc = data?["short_code"] as? String else {
                self.delegate?.dappCode(self, didChangeStatus: .error(.responseError(message: nil)))
                return
            }
            self.dappId = sc
            var image: UIImage?
            if let size = self.qrSize {
                image = self.generateQR(for: sc, width: size.width, height: size.height)
            }
            self.delegate?.dappCode(self, didChangeStatus: .created(sc, image))
        }
    }
    
    public func listen() {
        if let id = dappId {
            helper.listenToCode(id: id, delegate: self)
        }
    }
    
    public func stopListening() {
        helper.stopListening()
    }
    
    public static func getPushNotificationDestinations(_ onCompletion: @escaping ([DappWallet]?, DappError?) -> ()) {
        DappApiVendor.dappCodePushDestinations { (data, error) in
            if let e = error {
                onCompletion(nil, e)
                return
            }
            guard let json = data, let rc = json["rc"] as? Int else {
                onCompletion(nil, .responseError(message: nil))
                return
            }
            if rc != 0 {
                onCompletion(nil, .responseError(message: json["msg"] as? String))
                return
            }
            
            guard let walletsArray = json["data"] as? [[String: String]] else {
                onCompletion(nil, .responseError(message: nil))
                return
            }
            var wallets = [DappWallet]()
            for json in walletsArray {
                if let name = json["name"], let id = json["id"] {
                    wallets.append(DappWallet(id: id, name: name))
                }
            }
            onCompletion(wallets, nil)
        }
    }
    
    public func sendCoDiPushNotification(to phone: String, success: @escaping (Bool, DappError?) -> () ) {
        guard let code = dappId else {
            success(false, .pushNotificationInvalidCode)
            return
        }
        if phone.count != 10 || Int(phone) == nil {
            success(false, .invalidPhoneNumber)
            return
        }
        DappApiVendor.dappCodeCodiPush(code, phone: phone) { (data, error) in
            if let e = error {
                success(false, e)
                return
            }
            guard let json = data, let rc = json["rc"] as? Int else {
                success(false, .responseError(message: nil))
                return
            }
            if rc != 0 {
                success(false, .responseError(message: json["msg"] as? String))
                return
            }
            success(true, nil)
        }
    }
    
    public func sendPushNotification(to wallet: DappWallet, phone: String, success: @escaping (Bool, DappError?) -> () ) {
        guard let code = dappId else {
            success(false, .pushNotificationInvalidCode)
            return
        }
        if phone.count != 10 || Int(phone) == nil {
            success(false, .invalidPhoneNumber)
            return
        }
        DappApiVendor.dappCodePush(code, phone: phone, destination: wallet.id) { (data, error) in
            if let e = error {
                success(false, e)
                return
            }
            guard let json = data, let rc = json["rc"] as? Int else {
                success(false, .responseError(message: nil))
                return
            }
            if rc != 0 {
                success(false, .responseError(message: json["msg"] as? String))
                return
            }
            success(true, nil)
        }
    }
    
    private func generateQR(for code: String, width: CGFloat, height: CGFloat) -> UIImage {
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setDefaults()
        filter.setValue("https://dapp.mx/c/\(code)".data(using: .utf8, allowLossyConversion: false), forKey: "inputMessage")
        let outputImage = filter.outputImage!
        let scaleX = width / outputImage.extent.size.width
        let scaleY = height / outputImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        return UIImage(ciImage: outputImage.transformed(by: transform))
    }
    
    //MARK: - DappPOSCodeHelperDelegate
    internal func dappPOSCodeHelper(_ helper: DappPOSCodeHelper, codePayed payment: DappPayment) {
        delegate?.dappCode(self, didChangeStatus: .payed(payment))
    }
    
    internal func dappPOSCodeHelper(_ helper: DappPOSCodeHelper, didFailWithError error: DappError) {
        delegate?.dappCode(self, didChangeStatus: .error(error))
    }
}
