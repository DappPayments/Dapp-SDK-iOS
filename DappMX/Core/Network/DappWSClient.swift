//
//  DappWSClient.swift
//  Core
//
//  Created by Rodrigo Rivas on 4/6/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal enum DappSocketStatus {
    case connected
    case disconnected
    case data(String)
}

internal protocol DappSocketDelegate {
    func didChangeStatus(_ status: DappSocketStatus)
}

internal class DappWSClient {
    
    public var delegate: DappSocketDelegate?
    #if canImport(Starscream)
    private var socket: WebSocket!
    #endif
    
    public static func isAvailable() -> Bool {
        #if canImport(Starscream)
        return true
        #else
        return false
        #endif
    }
    
    public init(url: String, header: String? = nil) {
        #if canImport(Starscream)
        var request = URLRequest(url: URL(string: url)!)
        if let h = header {
            let authData = h.data(using: String.Encoding.utf8)!
            let base64 = authData.base64EncodedString()
            request.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        }
        socket = WebSocket(request: request)
        socket.delegate = self
        #endif
    }
    
    public func connect() {
        #if canImport(Starscream)
        socket.connect()
        #endif
    }
    
    public func disconnect() {
        #if canImport(Starscream)
        socket.disconnect()
        #endif
    }
    
    public func write(text: String) {
        #if canImport(Starscream)
        socket.write(string: text)
        #endif
    }

}

#if canImport(Starscream)
import Starscream

extension DappWSClient: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        delegate?.didChangeStatus(.connected)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        delegate?.didChangeStatus(.disconnected)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        delegate?.didChangeStatus(.data(text))
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        if let txt = String(data: data, encoding: .utf8) {
            delegate?.didChangeStatus(.data(txt))
        }
    }
}
#endif
