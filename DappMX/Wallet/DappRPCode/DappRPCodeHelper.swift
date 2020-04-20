//
//  DappRPCodeHelper.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal protocol DappRPCodeHelperDelegate: AnyObject {
    func dappRPCodeHelper(_ helper: DappRPCodeHelper, codePayed payment: DappPayment)
    func dappRPCodeHelper(_ helper: DappRPCodeHelper, codeRenewed code: String?, readExpiration: Date?, codeExpiration: Date?, timesRenewed: Int?)
    func dappRPCodeHelperDidDeleteCode(_ helper: DappRPCodeHelper)
    func dappRPCodeHelperCodeExpired(_ helper: DappRPCodeHelper)
    func dappRPCodeHelperCodeReadExpired(_ helper: DappRPCodeHelper)
    func dappRPCodeHelper(_ helper: DappRPCodeHelper, didfailedWithError error: DappError)
}

internal protocol DappRPCodeActionsDelegate: AnyObject {
    func listenToCode(id: String)
    func stopListening()
    func renewCode(id: String)
    func deleteCode(id: String)
}

internal class DappRPCodeHelper: DappRPCodeActionsDelegate {
    
    public weak var delegate: DappRPCodeHelperDelegate?
    
    private var id: String!
    
    private var codeExpiration: Date?
    
    private var readExpiration: Date?
    
    private var codeExpTimer: Timer!
    
    private var readExpTimer: Timer!
    
    private var statusTimer: Timer!
    
    private var retries = 0
    
    private var isListening = false
    
    private var canBeRenewed = true
    
    private var wsClient: DappWSClient?
    
    private var runLoop = RunLoop.current
    
    init(initialRenewExpiration: Date, initialReadExpiration: Date) {
        codeExpiration = initialRenewExpiration
        readExpiration = initialReadExpiration
    }
    
    private func setCodeExpiration(date: Date) {
        if date < Date() {
            stopListening()
            delegate?.dappRPCodeHelperCodeExpired(self)
            return
        }
        invalidateTimer(codeExpTimer)
        codeExpTimer = Timer(fire: date, interval: 0, repeats: false, block: { [weak self] (_) in
            guard let helper = self else {
                return
            }
            helper.stopListening()
            helper.delegate?.dappRPCodeHelperCodeExpired(helper)
        })
        runLoop.add(codeExpTimer, forMode: .default)
    }
    
    private func setReadExpiration(date: Date) {
        if date < Date() {
            delegate?.dappRPCodeHelperCodeReadExpired(self)
            return
        }
        invalidateTimer(readExpTimer)
        readExpTimer = Timer(fire: date, interval: 0, repeats: false, block: { [weak self] (_) in
            guard let helper = self else {
                return
            }
            helper.delegate?.dappRPCodeHelperCodeReadExpired(helper)
        })
        
        runLoop.add(readExpTimer, forMode: .default)
    }
    
    private func invalidateTimer(_ timer: Timer?) {
        if let t = timer {
            t.invalidate()
        }
    }
    
    public func listenToCode(id: String) {
        if isListening {
            return
        }
        if let exp = codeExpiration {
            if exp < Date() {
                delegate?.dappRPCodeHelperCodeExpired(self)
                return
            }
            setCodeExpiration(date: exp)
            if canBeRenewed, let exp = readExpiration {
                setReadExpiration(date: exp)
            }
        }
        isListening = true
        self.id = id
        if DappWSClient.isAvailable() {
            wsClient = DappApiWallet.paymentCodeSocket(id)
            wsClient?.delegate = self
            wsClient?.connect()
        }
        else {
            setStatusTimer()
        }
    }
    
    public func stopListening() {
        isListening = false
        invalidateTimer(statusTimer)
        invalidateTimer(codeExpTimer)
        invalidateTimer(readExpTimer)
        wsClient?.disconnect()
    }
    
    private func setStatusTimer() {
        statusTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(httpRequestCodeStatus), userInfo: nil, repeats: false)
    }
    
    @objc private func httpRequestCodeStatus() {
        DappApiWallet.paymentCodeStatus(id) { [weak self] (data, error) in
            guard let s = self, s.isListening else {
                return
            }
            if let e = error {
                switch e {
                case .error:
                    s.retries += 1
                    if s.retries >= 3 {
                        s.stopListening()
                        s.delegate?.dappRPCodeHelper(s, didfailedWithError: e)
                    }
                    else {
                        s.setStatusTimer()
                    }
                default:
                    s.stopListening()
                    s.delegate?.dappRPCodeHelper(s, didfailedWithError: e)
                }
                return
            }
            
            if let d = data {
                s.stopListening()
                s.delegate?.dappRPCodeHelper(s, codePayed: DappPayment(with: d))
                return
            }
            s.setStatusTimer()
        }
    }
    
    public func renewCode(id: String) {
        if DappWSClient.isAvailable() {
            let dic = ["cmd": "renew"]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted), let json = String(data: jsonData, encoding: .utf8) else {
                return
            }
            wsClient?.write(text: json)
            return
        }
        
        DappApiWallet.renewPaymentCode(id) { [weak self] (data, error) in
            guard let s = self else { return }
            if let d = data {
                s.rpCodeRenewed(with: d)
                return
            }
            
            s.delegate?.dappRPCodeHelper(s, didfailedWithError: .renewDappRPCodeFailed)
        }
    }
    
    private func rpCodeRenewed(with data: [String: Any]) {
        let qrCode = data["qr_code"] as? String
        let timesRenewed = data["impresion_num"] as? Int
        readExpiration = dateFromString(data["read_expiration"] as? String)
        codeExpiration = dateFromString(data["renew_expiration"] as? String)
        if let t = timesRenewed {
            if t < 5 {
                if let exp = readExpiration {
                    setReadExpiration(date: exp)
                }
                
                if let exp = codeExpiration {
                    setCodeExpiration(date: exp)
                }
            }
            else {
                canBeRenewed = false
                invalidateTimer(readExpTimer)
                codeExpiration = readExpiration //si es la última vez q se renueva, el código se expira al momento que ya no se puede leer
                if let exp = codeExpiration {
                    setCodeExpiration(date: exp)
                }
            }
        }
        else {
            if let exp = readExpiration {
                setReadExpiration(date: exp)
            }
            
            if let exp = codeExpiration {
                setCodeExpiration(date: exp)
            }
        }
        
        delegate?.dappRPCodeHelper(self, codeRenewed: qrCode, readExpiration: readExpiration, codeExpiration: codeExpiration, timesRenewed: timesRenewed)
    }
    
    public func deleteCode(id: String) {
        if DappWSClient.isAvailable() {
            let dic = ["cmd": "delete"]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted), let json = String(data: jsonData, encoding: .utf8) else {
                return
            }
            wsClient?.write(text: json)
            return
        }
        stopListening()
        DappApiWallet.deletePaymentCode(id) { [weak self] (data, error) in
            guard let s = self else { return }
            if error != nil {
                s.delegate?.dappRPCodeHelper(s, didfailedWithError: .deleteDappRPCodeFailed)
                s.listenToCode(id: id)
                return
            }
            
            s.delegate?.dappRPCodeHelperDidDeleteCode(s)
        }
    }
    
    private func dateFromString(_ date: String?) -> Date? {
        guard let d = date else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX"
        if let d = dateFormatter.date(from: d) {
            return d
        }
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
        return dateFormatter.date(from: d)
    }
    
}

extension DappRPCodeHelper: DappSocketDelegate {
    
    func didChangeStatus(_ status: DappSocketStatus) {
        switch status {
        case .connected:
            break
        case .disconnected:
            if isListening {
                httpRequestCodeStatus()
            }
        case .data(let txt):
            if let data = txt.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let rc = json["rc"] as? Int {
                switch rc {
                case 0:
                    stopListening()
                    if let data = json["data"] as? [String: Any] {
                        delegate?.dappRPCodeHelper(self, codePayed: DappPayment(with: data))
                    }
                case 1:
                    if let d = json["data"] as? [String: Any] {
                        rpCodeRenewed(with: d)
                    }
                case 20:
                    stopListening()
                    delegate?.dappRPCodeHelperDidDeleteCode(self)
                case -8513:
                    delegate?.dappRPCodeHelper(self, didfailedWithError: .renewDappRPCodeFailed)
                default:
                    break
                }
            }
        }
    }
}
