//
//  DappPayment.swift
//  Dapp SDK iOS
//
//  Created by Rodrigo Rivas Torres on 02/06/17.
//  Copyright © 2017 Dapp. All rights reserved.
//

import Foundation

public protocol DappPaymentDelegate {
    
    func dappPaymentFailure(error: DappError)
    
    func dappPaymentSuccess(payment: DappPayment)
}

public class DappPayment {
    
    public var id: String!
    public var amount: Double!
    public var tip: Double!
    public var date: Date!
    public var description: String!
    public var reference: String?
    public var currency: String!
    public var client: String!
    
    init(with data: [String: Any]) {
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
        
        if let stringDate = data["date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .iso8601)
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX"
            self.date = dateFormatter.date(from: stringDate)
        }
    }
}
