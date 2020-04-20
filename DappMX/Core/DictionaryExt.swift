//
//  DictionaryExt.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/31/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal extension Dictionary where Key == String {
    func query() -> String {
        return self.map({ $0.key + "=\($0.value)" }).joined(separator: "&")
    }
}
