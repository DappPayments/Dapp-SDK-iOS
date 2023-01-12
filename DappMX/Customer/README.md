# Dapp Customer SDK for iOS

Este SDK esta pensado para las aplicaciones de negocios con ventas no presenciales.  Puedes realizar solicitudes de pago a los wallets integrados en el ecosistema a través del Dapp Checkout.

## INSTALACIÓN
Recomendamos utilizar CocoaPods para integrar Dapp Customer SDK
```
platform :ios, '11.0'
pod 'DappCustomer', '~> 4.0.0'
```
## CONFIGURACIÓN
1. Agrega la siguiente instrucción de importación: 
```swift
import DappCustomer
```
2. Inicializa la instancia del objeto Dapp reemplazando _your-dapp-api-key_ con tu clave:
```swift
Dapp.shared.apiKey = "your-dapp-api-key"
```
3. Puedes realizar pruebas de las funcionalidades de este SDK cambiando el ambiente a modo **sandbox**
```swift
Dapp.shared.enviroment = .sandbox
```

## REALIZAR COBROS A TRAVÉS DE DAPP CHECKOUT
Para realizar cobros dentro de Dapp, los comercios deben generar códigos de cobro que serán pagados por el cliente a través de su aplicación preferida. El cliente puede elegir esta aplicación de manera transparente para el comercio a través de la plataforma Dapp Checkout.

1. Inicializa un objeto DappCode, asignale un delegado y utiliza la función **create**, esta llamada es asíncrona.
2. Adopta el protocolo _DappCodeDelegate_ e implementa sus métodos para recibir información asociada al código de cobro.
3. Una vez creado el DappCode, crea una instancia de la clase _DappCheckoutViewController_ y preséntalo.
4. Cuando el usuario haya realizado el pago, el _DappCheckoutViewController_ se dejará de presentar y recibirás una notificación de cambio de estatus a pagado en el _DappCodeDelegate_ que implementaste.
```swift
import DappCustomer

class ViewController: UIViewController, DappPOSCodeDelegate {
    
    var code: DappCode!
    
    func generateDappCode(amount: Double, description: String, reference: String?) {
        code = DappCode(amount: amount, description: description)
        code.delegate = self
        code.create() //async call, handle UI: show loader
    }
    
    //MARK: - DappPOSCodeDelegate
    func dappCode(_ dappCode: DappPOSCode, didChangeStatus status: DappPOSCodeStatus) {
        //handle results...
        switch status {
        case .created:
            //dappCode created, handle UI: dismiss loader, present checkout
            let vc = DappCheckoutViewController(dappCode: dappCode)
            present(vc, animated: true, completion: nil)
            break
        case .payed(let payment):
            //payment received, checkout has been dismissed, handle UI
            break
        case .error(let error):
            //error in payment, handle UI
            break
        }
    }
```

## LICENCIA
[MIT](../../LICENSE.txt)

