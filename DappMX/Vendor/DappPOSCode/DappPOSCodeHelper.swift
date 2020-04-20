//
//  DappPOSCodeHelper.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/31/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal protocol DappPOSCodeHelperDelegate: AnyObject {
    func dappPOSCodeHelper(_ helper: DappPOSCodeHelper, codePayed payment: DappPayment)
    func dappPOSCodeHelper(_ helper: DappPOSCodeHelper, didFailWithError error: DappError)
}

internal protocol DappPOSCodeActionsDelegate: AnyObject {
    func listenToCode(id: String, delegate: DappPOSCodeHelperDelegate)
    func stopListening()
}

internal class DappPOSCodeHelper: DappPOSCodeActionsDelegate {
    
    public var delegate: DappPOSCodeHelperDelegate?
    
    private var id: String!
    
    private var timer: Timer!
    
    private var retries = 0
    
    private var isListening = false
    
    private var wsClient: DappWSClient?
    
    public func listenToCode(id: String, delegate: DappPOSCodeHelperDelegate) {
        if isListening {
            return
        }
        isListening = true
        self.delegate = delegate
        self.id = id
        if DappWSClient.isAvailable() {
            wsClient = DappApiVendor.dappCodeSocket(id)
            wsClient?.delegate = self
            wsClient?.connect()
        }
        else {
            setTimer()
        }
    }
    
    public func stopListening() {
        isListening = false
        if let t = timer {
            t.invalidate()
        }
        wsClient?.disconnect()
        delegate = nil
    }
    
    private func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(httpRequestCodeStatus), userInfo: nil, repeats: false)
    }
    
    @objc private func httpRequestCodeStatus() {
        DappApiVendor.dappCodePayment(id) { (data, error) in
            if let e = error {
                switch e {
                case .error:
                    self.retries += 1
                    if self.retries >= 3 {
                        self.delegate?.dappPOSCodeHelper(self, didFailWithError: e)
                        self.stopListening()
                    }
                    else {
                        self.setTimer()
                    }
                default:
                    self.delegate?.dappPOSCodeHelper(self, didFailWithError: e)
                    self.stopListening()
                }
                return
            }
            
            if let d = data {
                self.delegate?.dappPOSCodeHelper(self, codePayed: DappPayment(with: d))
                self.stopListening()
                return
            }
            self.setTimer()
        }
    }
}

extension DappPOSCodeHelper: DappSocketDelegate {
    
    func didChangeStatus(_ status: DappSocketStatus) {
        switch status {
        case .connected:
            break
        case .disconnected:
            if isListening {
                httpRequestCodeStatus()
            }
        case .data(let txt):
            if let data = txt.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                isListening = false
                delegate?.dappPOSCodeHelper(self, codePayed: DappPayment(with: json))
            }
        }
    }
}
