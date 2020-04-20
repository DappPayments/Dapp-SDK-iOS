//
//  DappRPCodeVendor.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/30/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

public final class DappRPCode: DappRPCodeProtocol {
    
    public var qrString: String?
    
    public init(_ qrString: String) {
        self.qrString = qrString
    }
    
    public func charge(_ amount: Double, description: String, reference: String? = nil, onCompletion: @escaping (DappPayment?, DappError?) -> ()) {
        DappApiVendor.paymentCode(qrString!, amount: amount, description: description, reference: reference) { (data, error) in
            if let e = error {
                onCompletion(nil, e)
                return
            }
            
            guard let d = data else {
                onCompletion(nil, .responseError(message: nil))
                return
            }
            onCompletion(DappPayment(with: d), nil)
        }
    }
}
