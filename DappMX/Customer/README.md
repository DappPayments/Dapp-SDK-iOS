# Dapp Customer SDK for iOS

Este SDK esta pensado para las aplicaciones de negocios con ventas no presenciales  y cuenta con dos funcionalidades:
 - Tokenizar tarjetas.
 - Realizar solicitudes de pago a los wallets integrados en el ambiente Dapp.

## INSTALACIÓN
Recomendamos utilizar CocoaPods para integrar Dapp Customer SDK
```
platform :ios, '11.0'
pod 'DappCustomer', '~> 2.2.1'
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
## TOKENIZAR TARJETAS
Tokeniza las tarjetas de tus usuarios, guarda la referencia en tu base de datos y realiza pagos con esa tarjeta cuando lo desee el usuario.
```swift
import DappCustomer

class ViewController: UIViewController {

override func viewDidLoad() {
    super.viewDidLoad()
}

func tokenizeCardButton() {
    let card: String = "5515150180013278"
    let name: String = "Daenerys Targaryen"
    let cvv: String = "123"
    let month: String = "01"
    let year: String = "2030"
    let mail: String = "daenerys@gameofthrones.com"
    let phone: String = "5512345678"
    
    //prepare UI for the async call
    DappCard.add(card, cardholder: name, cvv: cvv, expMonth: month, expYear: year, email: mail, phoneNumber: phone) { (card, error) in
    //handle the response results
        if let c = card {
        print(c.token!)
        }
        else {
        print(error!.localizedDescription)
        }
    }
}

```
## REALIZAR PAGOS
Realiza solicitudes de pago a cualquier walllet integrado al ambiente Dapp que el usuario tenga instalado en su dispositivo.

1. Configurar el archivo **info.plist**. Haz clic con el botón derecho en el archivo info.plist y elige **Open As Source Code**. Copia y pega el siguiente fragmento de código XML en el cuerpo de tu archivo. Cambia el valore de _uniqueappid_  con datos únicos referentes a tu aplicación
```xml    
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>dappmxqrpago</string>
    <string>dappmxsantander</string>
</array>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>uniqueappid</string>
        </array>
    </dict>
</array>
```
2. Asegurate que exista un wallet instalado en el dispositivo de tu usuario con la función **DappCode.paymentsAvailable()**

3. Crea un objeto DappCode, asigna un delegado para poder obtener la respuesta del pago y utiliza la funcion **pay(from:)**
```swift
import DappCustomer

class ViewController: UIViewController, DappCodeDelegate {

    var dappCode: DappCode!

    override func viewDidLoad() {
    super.viewDidLoad()
    }
    
    func paymentButton() {
        if DappCode.paymentsAvailable() {
            dappCode = DappCode(amount: 100, description: "descripción de la venta")        
            dappCode.delegate = self
            dappCode.pay(from: self)
        }
        else {
        //alternate flow...
        }
    }
    
    func dappCode(_ code: DappCode, didSucceedWithPayment paymentId: String) {
        //handle success validations...
        print(paymentId)
    }
    
    func dappCode(_ code: DappCode, didFailWithError error: DappError) {
        //handle error...
        print(error)
    }
```
4. Agrega el metodo **application(\_:open:options)** en el **AppDelegate**
```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    let handled = Dapp.application(app, open: url, options: options)
    return handled
}
```
## LICENCIA
[MIT](../../LICENSE.txt)
