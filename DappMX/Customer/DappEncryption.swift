//
//  DappEncryption.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/26/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal struct DappEncryption {
    
    internal static func encrypt(_ string: String) -> String {
        let key = getPublicKey()
        let keyData = Data(base64Encoded: key)!
        let attributes: [String: Any] = [
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048
        ]
        //var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, nil) else {
            //print(error!.takeRetainedValue())
            return ""
        }
        
        let dataMsg = string.data(using: .utf8)!
        guard let encryptedData = SecKeyCreateEncryptedData(secKey, .rsaEncryptionOAEPSHA1, dataMsg as CFData, nil) else {
            //print(error!.takeRetainedValue())
            return ""
        }
        
        return (encryptedData as Data).base64EncodedString().addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    }
   
    internal static func getPublicKey() -> String {
        switch Dapp.shared.enviroment {
        case .production:
            if let filePath = Bundle(for: Dapp.self).path(forResource: "dapp_prod", ofType: "pem"), let contents = try? String(contentsOfFile: filePath) {
                var array = contents.components(separatedBy: "\n")
                array.removeLast()
                array.removeLast()
                array.removeFirst()
                return array.joined(separator: "")
            }
            return ""
        case .sandbox:
            if let filePath = Bundle(for: Dapp.self).path(forResource: "dapp_sandbox", ofType: "pem"), let contents = try? String(contentsOfFile: filePath) {
                var array = contents.components(separatedBy: "\n")
                array.removeLast()
                array.removeLast()
                array.removeFirst()
                return array.joined(separator: "")
            }
            return ""
        }
    }

}
