//
//  DappPaymentExt.swift
//  DappVendor
//
//  Created by Rodrigo Rivas on 04/01/22.
//  Copyright © 2022 Dapp. All rights reserved.
//

import Foundation

public extension DappPayment {
    
    static func getPayments(startDate: Date, endDate: Date, onCompletion: @escaping ([DappPayment]?, DappError?) -> ()) {
        DappApiVendor.getPayments(startDate, endDate: endDate) { data, error in
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
            
            guard let paymentsArray = json["data"] as? [[String: Any?]] else {
                onCompletion(nil, .responseError(message: nil))
                return
            }
            var payments = [DappPayment]()
            for json in paymentsArray {
                payments.append(DappPayment(with: json))
            }
            onCompletion(payments, nil)
        }
    }
}
