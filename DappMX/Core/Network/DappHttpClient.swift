//
//  DappHttpClient.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal typealias DappHttpResponse = (_ data: [String: Any]?, _ error: DappError?) -> ()

internal class DappHttpClient {
    
    public static func request(url: String, authHeader: String, params: String? = nil, method: String? = nil, defaultRc: Bool = true, onCompletion: @escaping DappHttpResponse) {
        var request = URLRequest(url: URL(string: url)!)
        if let p = params {
            request.httpMethod = "POST"
            request.httpBody = p.data(using: .utf8)
        }
        if let m = method {
            request.httpMethod = m
        }
        let authData = authHeader.data(using: String.Encoding.utf8)!
        let base64 = authData.base64EncodedString()
        request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let e = error {
                DispatchQueue.main.async {
                    onCompletion(nil, .error(e))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    onCompletion(nil, .responseError(message: nil))
                }
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                DispatchQueue.main.async {
                    onCompletion(nil, .responseError(message: nil))
                }
                return
            }
            
            if !defaultRc {
                DispatchQueue.main.async {
                    onCompletion(json, nil)
                }
                return
            }
            
            guard let rc = json["rc"] as? Int else {
                DispatchQueue.main.async {
                    onCompletion(nil, .responseError(message: nil))
                }
                return
            }
            
            if rc != 0 {
                DispatchQueue.main.async {
                    onCompletion(nil, .responseError(message: json["msg"] as? String))
                }
                return
            }
            
            guard let jsonData = json["data"] as? [String: Any] else {
                DispatchQueue.main.async {
                    onCompletion(nil, nil)
                }
                return
            }
            DispatchQueue.main.async {
                onCompletion(jsonData, nil)
            }
        }
        task.resume()
    }
}
