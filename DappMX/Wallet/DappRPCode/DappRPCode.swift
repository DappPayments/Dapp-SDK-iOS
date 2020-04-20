//
//  DappRPCode.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

public enum DappRequestToPayCodeStatus {
    case payed(DappPayment)
    case needsToBeRenewed
    case renewed
    case deleted
    case expired
    case error(DappError)
}

public protocol DappRPCodeDelegate: AnyObject {
    func dappRPCode(_ dappRPCode: DappRPCode, didChangeStatus status: DappRequestToPayCodeStatus)
}

public final class DappRPCode: DappRPCodeProtocol, DappRPCodeHelperDelegate {
    
    public var qrString: String?
    public var readExpiration: Date?
    public var renewExpiration: Date?
    public weak var delegate: DappRPCodeDelegate?
    
    
    private var id: String
    private var timesRenewed: Int?
    private var helper: DappRPCodeHelper!
    
    private final let MAX_RENEW_TIMES = 5
    
    public init(id: String, readExpiration: Date, renewExpiration: Date) {
        self.id = id
        self.readExpiration = readExpiration
        self.renewExpiration = renewExpiration
        helper = DappRPCodeHelper(initialRenewExpiration: renewExpiration, initialReadExpiration: readExpiration)
        helper.delegate = self 
    }
    
    public func isReadable() -> Bool {
        guard let readExp = readExpiration else {
            return true
        }
        return Date() > readExp
    }
    
    public func isRenewable() -> Bool {
        guard let renewExp = renewExpiration, let n = timesRenewed else {
            return true
        }
        return Date() > renewExp && n < MAX_RENEW_TIMES
    }
    
    public func listen() {
        helper.listenToCode(id: id)
    }
    
    public func stopListening() {
        helper.stopListening()
    }
    
    public func renew() {
        helper.renewCode(id: id)
    }
    
    public func delete() {
        helper.deleteCode(id: id)
    }
    

    //MARK: - DappRPCodeHelperDelegate
    internal func dappRPCodeHelper(_ helper: DappRPCodeHelper, codePayed payment: DappPayment) {
        delegate?.dappRPCode(self, didChangeStatus: .payed(payment))
    }
    
    internal func dappRPCodeHelper(_ helper: DappRPCodeHelper, codeRenewed code: String?, readExpiration: Date?, codeExpiration: Date?, timesRenewed: Int?) {
        qrString = code
        self.readExpiration = readExpiration
        self.renewExpiration = codeExpiration
        self.timesRenewed = timesRenewed
        delegate?.dappRPCode(self, didChangeStatus: .renewed)
    }
    
    internal func dappRPCodeHelperDidDeleteCode(_ helper: DappRPCodeHelper) {
        delegate?.dappRPCode(self, didChangeStatus: .deleted)
    }
    
    internal func dappRPCodeHelperCodeExpired(_ helper: DappRPCodeHelper) {
        delegate?.dappRPCode(self, didChangeStatus: .expired)
    }
    
    func dappRPCodeHelperCodeReadExpired(_ helper: DappRPCodeHelper) {
        delegate?.dappRPCode(self, didChangeStatus: .needsToBeRenewed)
    }
    
    internal func dappRPCodeHelper(_ helper: DappRPCodeHelper, didfailedWithError error: DappError) {
        delegate?.dappRPCode(self, didChangeStatus: .error(error))
    }
}
