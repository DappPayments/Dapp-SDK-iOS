//
//  DappApi.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/26/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal class DappApiCustomer: DappPOSApiProtocol {
    
    static func walletSchemes(_ onCompletion: @escaping DappHttpResponse) {
        httpRequest(path: "wallets/schemes/ios", defaultRc: false, onCompletion: onCompletion)
    }
}
