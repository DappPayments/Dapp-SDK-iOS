//
//  DappPayment.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

public enum DappPaymentType: Int {
    case balance = 0, credit = 1, debit = 2, codi = 5
}

public struct DappPayment {
    
    public var id: String!
    public var amount: Double!
    public var tip: Double!
    public var date: Date!
    public var description: String!
    public var reference: String?
    public var currency: String!
    public var client: String!
    public var paymentType: DappPaymentType!
    public var cardLastFour: String?
    
    internal init(with data: [String: Any?]) {
        if let id = data["id"] as? String {
            self.id = id
        }
        
        if let amount = data["amount"] as? Double {
            self.amount = amount
        }
        
        if let tip = data["tip"] as? Double {
            self.tip = tip
        }
        
        if let desc = data["description"] as? String {
            self.description = desc
        }
        
        if let ref = data["reference"] as? String {
            self.reference = ref
        }
        
        if let curr = data["currency"] as? String {
            self.currency = curr
        }
        
        if let client = data["client"] as? String {
            self.client = client
        }
        
        if let paymentInfo = data["payment"] as? [String: Any] {
            if let pt = paymentInfo["type"] as? Int {
                self.paymentType = DappPaymentType(rawValue: pt)
            }
            else if let paymentType = paymentInfo["type"] as? String, let pt = Int(paymentType) {
                self.paymentType = DappPaymentType(rawValue: pt)
            }
            if let last4 = paymentInfo["last_4"] as? String {
                self.cardLastFour = last4
            }
        }
        
        if let stringDate = data["date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .iso8601)
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX"
            self.date = dateFormatter.date(from: stringDate)
        }
    }
}
