//
//  BaseDappCode.swift
//  DappMX
//
//  Created by Rodrigo Rivas on 3/23/20.
//  Copyright © 2020 Dapp. All rights reserved.
//

import Foundation

internal protocol DappCodeProtocol {
    var dappId: String? { get set } //opcional xq los codigos CoDi no llevan dappId
    var amount: Double! { get set } //es opcional xq DappCodeWallet no lo inicialza hasta que se utiliza la funcion read
    var description: String! { get set } //es opcional xq DappCodeWallet no lo inicialza hasta que se utiliza la funcion read
    var reference: String? { get set }
}
