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