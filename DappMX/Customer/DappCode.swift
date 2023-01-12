//
//  DappPOSCode.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/27/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import UIKit

public protocol DappCodeDelegate: AnyObject {
    func dappCode(_ dappCode: DappCode, didChangeStatus status: DappCodeStatus)
}

public enum DappCodeStatus {
    case created
    case error(DappError)
    case payed(DappPayment)
}

public class DappCode: DappPOSCodeProtocol {
    
    internal var dappId: String?
    public var amount: Double!
    public var tip: Double?
    public var description: String!
    public var reference: String?
    public weak var delegate: DappCodeDelegate?

    public required init(amount: Double, description: String, reference: String? = nil, tip: Double? = nil) {
        self.amount = amount
        self.description = description
        self.reference = reference
        self.tip = tip
    }
    
    public func create() {
        if dappId != nil {
            print("Dapp: DappPOSCode has already been created before.")
            return
        }
        
        DappApiCustomer.dappCode(amount: amount, description: description, reference: reference, tip: tip) { (data, error) in
            if let e = error {
                self.delegate?.dappCode(self, didChangeStatus: .error(e))
                return
            }
            guard let sc = data?["id"] as? String else {
                self.delegate?.dappCode(self, didChangeStatus: .error(.responseError(message: nil)))
                return
            }
            self.dappId = sc
            self.delegate?.dappCode(self, didChangeStatus: .created)
        }
    }
    
    
}
