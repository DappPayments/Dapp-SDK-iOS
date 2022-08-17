//
//  BaseDappPOSCode.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal protocol DappPOSCodeProtocol: DappCodeProtocol {
    var tip: Double? { get set }
    init(amount: Double, description: String, reference: String?, tip: Double?)
    func create()
}
