# Dapp iOS SDK
[Dapp](https://dapp.mx) es una plataforma de pagos, enfocada en la seguridad de sus usuarios. Este SDK es la forma m�s f�cil de integrar Dapp en tu desarrollo iOS y cuenta con dos funcionalidades: **tokenizar tarjetas** y **realizar pagos**.

## INSTALACI�N
Recomendamos utilizar cocoapods para integrar Dapp iOS SDK
```
platform :ios, '9.0'
pod 'DappMX'
```

## CONFIGURACI�N
Para obtener tu _merchant\_id_ y _api\_key_ entra en tu [dashboard](https://dapp.mx/dashboard) y selecciona la opci�n �developer� del men� lateral. Agrega tus claves de la siguiente manera:

1. Agrega la siguiente instrucci�n de importaci�n: 
```swift
import DappMX
```
2. Inicializa las claves en el objeto Dapp reemplazando _your-dapp-merchant-id_ y _your-dapp-api-key_ con tus claves:
```swift
Dapp.shared.merchantId = "your-dapp-merchant-id"
Dapp.shared.apiKey = "your-dapp-api-key"
```
3. Puedes realizar pruebas sin realizar pagos reales cambiando el ambiente a _sandbox_
```swift
Dapp.shared.enviroment = .sandbox
```
## REALIZAR PAGOS
Realiza pagos a trav�s de la [aplicaci�n iOS](https://itunes.apple.com/mx/app/dapp/id1271831127?mt=8) de Dapp.

1. Agrega el metodo **application(\_:open:options)** en el **AppDelegate**
```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
	let handled = Dapp.application(app, open: url, options: options)
	return handled
}
```
2. Configurar el archivo **info.plist**. Haz clic con el bot�n derecho en el archivo info.plist y elige **Open As Source Code**. Copia y pega el siguiente fragmento de c�digo XML en el cuerpo de tu archivo. Cambia los valores _uniqueappid_ y _YourAppName_ con los datos �nicos referentes a tu aplicaci�n
```xml    
<key>LSApplicationQueriesSchemes</key>
    <array>
        <string>dappmx</string>
    </array>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>uniqueappid</string>
            </array>
            <key>CFBundleURLName</key>
            <string>YourAppName</string>
        </dict>
    </array>
```
3. Asigna un delegado de pago e implementa sus m�todos
```swift
import DappMX

class ViewController: UIViewController, DappPaymentDelegate {

override func viewDidLoad() {
	super.viewDidLoad()
	Dapp.shared.paymentDelegate = self
}

func dappPaymentFailure(error: DappError) {
	//your code to handle the error
	print(error.localizedDescription)
	switch error {
	default:
		break
	}
}
    
func dappPaymentSuccess(payment: DappPayment) {
	//your code to handle the success
}
```
4. Implementa el m�todo de pago
```swift
let vc: UIViewController = self
let price: Double: 100
let desc: String = "Payment description"
let ref: String = "MyCompanyInnerReference"

Dapp.requestPayment(viewController: vc, amount: price, description: desc, reference: ref)
```
5. En caso de que el usuario no tenga instalado Dapp en su dispositivo, el m�todo abre el [AppStore](https://itunes.apple.com/mx/app/dapp/id1271831127?mt=8) para que descargue la aplicaci�n. Si deseas un flujo alterno utiliza la funci�n isDappInstalled()
```swift
if Dapp.isDappInstalled() {
	//call Dapp.requestPayment(viewController: UIViewController, amount: Double, description: String, reference: String?)
}
else {
	//your alternate flow
}
```
## TOKENIZAR TARJETAS
Tokeniza tarjetas, guarda la referencia en tu base de datos y realiza pagos con esa tarjeta cuando sea necesario.

1. Asigna un delegado e implementa sus m�todos
```swift
import DappMX

class ViewController: UIViewController, DappPaymentDelegate {

override func viewDidLoad() {
	super.viewDidLoad()
	Dapp.shared.cardDelegate = self
}

func dappCardSuccess(card: DappCard) {
	//your code to handle success
	print(card.token)
}
 
func dappCardFailure(error: DappError) {
	//your code to handle the error
	print(error.localizedDescription)
	switch error {
	default:
		break
	}
}
```
2. Utiliza el siguiente m�todo para tokenizar las tarjetas de tus clientes
```swift
let card: String = "5515150180013278"
let name: String = "Daenerys Targaryen"
let cvv: String = "123"
let month: String = "01"
let year: String = "2030"
let mail: String = "daenerys@gameofthrones.com"
let phone: String = "5512345678"

Dapp.addCard(cardNumber: card, cardholder: name, cvv: cvv, expMonth: month, expYear: year, email: mail, phoneNumber: phone)
```
## LICENCIA
[MIT](LICENSE.txt)