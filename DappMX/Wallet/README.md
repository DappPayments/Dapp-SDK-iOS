# Dapp Wallet SDK for iOS
Este SDK esta pensado para los Wallets electrónicos integrados al ambiente Dapp. Su función principal es leer códigos QR POS integrados al ambiente Dapp.

## INSTALACIÓN
Recomendamos utilizar CocoaPods para integrar Dapp Wallet SDK
```ruby
platform :ios, '11.0'
pod 'DappWallet', '~> 3.0.0'
```
De forma estándar el SDK monitorea el estado de los códigos QR Request to Pay vía peticiones HTTP.  Existe una versión alternativa que sigue el estado del código QR a través de WebSockets con ayuda de la librería [Starscream](https://github.com/daltoniam/Starscream/). Si deseas utilizar esta versión incluye esta línea en  lugar de la anterior:
```ruby
pod 'DappWallet/Socket', '~> 3.0.0'
```
## CONFIGURACIÓN
1. Agrega la siguiente instrucción de importación: 
```swift
import DappWallet
```
2. Inicializa la instancia del objeto Dapp reemplazando _your-dapp-api-key_ con tu clave:
```swift
Dapp.shared.apiKey = "your-dapp-api-key"
```
3. Puedes realizar pruebas de las funcionalidades de este SDK cambiando el ambiente a modo **sandbox**
```swift
Dapp.shared.enviroment = .sandbox
```
## CÓDIGOS QR POS

Los códigos QR POS, son códigos generados por negocios integrados al ambiente Dapp, diseñados para que los clientes puedan leer la información del cobro y pagar.

En caso de que el wallet ya cuente con un lector de códigos QR propio, valida y recibe la información de pago creando un objeto *DappPOSCode* con el valor del código QR y llama a la función **read(onCompletion:)**
```swift
import DappWallet

class ViewController: UIViewController {
    
    var dappCode: DappPOSCode!
    
    func codeScanned(qrTextFromScanner: String) {
    //prepare UI for the async call
        dappCode = DappPOSCode(qrTextFromScanner)
        dappCode.read { (error) in
            if let e = error {
               //handle error
               print(e.localizedDescription)
            }
            else {
        //handle success
        print(dappCode.amount!)
        print(dappCode.description!)
            }
        }
    }

```
El ambiente Dapp incluye códigos QR de diversas fuentes. En caso de ser un código hecho por Dapp puedes obtener el dapp ID de la siguiente manera:
```swift
if let id = dappCode.dappId {
    print(id)
}
```
**Dapp Wallet SDK iOS** también es compatible con CoDi. Existen dos funciones que puedes utilizar:
```swift
dappCode.isCodi() //true or false
dappCode.getQRType() //.codi, .dapp, .codiDapp, .unknown
```
## LECTOR DE CÓDIGOS QR POS

Las funciones del lector se pueden implementar de dos formas:

 - **Como view controller**:  Más rápido y sencillo. Crea un _DappPOSCodeScannerViewController_ y preséntalo. Éste view controller se encarga de obtener la información de los códigos QR Dapp y de todos los aspectos relacionados con el UX.
 - **Como view** : Más flexible. Crea un _DappScannerView_ que solo se encargará de leer el código QR. Esto te permite implementar un UX que vaya más acorde con tu aplicación.

Cualquier opción que elijas, es necesario configurar el archivo **Info.plist**. Añade la propiedad [_NSCameraUsageDescription_](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW24)  junto con un valor de tipo _string_ describiendo por que tu app requiere del uso de la cámara (Por ej: "Escanea códigos QR"). Este texto se muestra al usuario cuando la app pide permiso para utilizar la cámara por primera vez.

### Integra el lector como view controller

1. Adopta el protocolo **DappPOSCodeScannerViewControllerDelegate** e implementa sus métodos para recibir información asociada al código QR.
```swift
import DappWallet

class ViewController: UIViewController, DappPOSCodeScannerViewControllerDelegate {

    //MARK: - DappPOSCodeScannerViewControllerDelegate
    func dappScannerViewController(_ viewController: DappScannerViewController, didScanCode code: DappPOSCode) {
        //handle code scanned
        viewController.dismiss(animated: true, completion: nil)
        print(code.amount!)
        print(code.description!)
    }
    
    func dappScannerViewController(_ viewController: DappScannerViewController, didFailWithError error: DappError) {
        print(error.localizedDescription)
    }
```
2. Presenta el _DappPOSCodeScannerViewController_.
```swift
    @IBAction func scanQR(_ sender: Any) {
        let vc = DappPOSCodeScannerViewController(delegate: self) //self == ViewController
        present(vc, animated: true, completion: nil)
    }
```
### Integra el lector como view
1. Adopta el protocolo **DappScannerViewDelegate** e implementa los métodos para recibir la lectura del código QR.
```swift
import DappWallet

class ViewController: UIViewController, DappScannerViewDelegate {

    //MARK: - DappScannerViewDelegate
    func dappScannerView(_ scannerView: DappScannerView, didScanCode code: String) {
        //handle text scanned from QR code
        scannerView.stopScanning()
        print(code)
        let code = DappPOSCode(code)
        code.read { (error) in
            if let e = error {
                print(e)
                return
            }
            print(code.amount!)
            print(code.description!)
        }
    }
    
    func dappScannerView(_ scannerView: DappScannerView, didFailWithError error: DappError) {
        print(error)
    }
```
2. Agrega un _DappScannerView_ a tu view controller vía storyboard o código y asigna el delegate
```swift
    @IBOutlet var scannerView: DappScannerView!

     override public func viewDidLoad() {
        super.viewDidLoad()
        //scannerView = DappScannerView(frame:  CGRect(x: 0, y: 0, width: 100, height: 100))
        //view.addSubview(scannerView)
        scannerView.delegate = self
        //customize scanner
        scannerView.showQRFrame = true
        scannerView.successFrameColor = .green
        scannerView.failureFrameColor = .red
    }
```
3. Para empezar escanear, utiliza la función _startScanning_
```swift
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scannerView.startScanning()
    }
```
4. Para parar el scanner, utiliza la función _stopScanning_
```swift
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scannerView.startScanning()
    }
```
5. En caso de necesitar saber si el lector está activo utilice la funcion _isScanning_
```swift
scannerView.isScanning()
```
6. Notifica al scanner en caso de que el código escaneado es inválido con la función _qrScannedFailed_
```swift
scannerView.qrScannedFailed()
```
## REALIZAR PAGOS A CODIGOS POS
Puedes recibir solicitudes de pago de cualquier app de negocio integrado al ambiente Dapp que el usuario tenga instalado en su dispositivo.

1. Configurar el archivo **info.plist**. Haz clic con el botón derecho en el archivo info.plist y elige **Open As Source Code**. Copia y pega el siguiente fragmento de código XML en el cuerpo de tu archivo. Cambia el valor de _[APP_ID]_  con el identificador de tu app.
```xml    
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>dapp[APP_ID]</string>
        </array>
    </dict>
</array>
```
2. Agrega el metodo **application(\_:open:options)** en el **AppDelegate**. Crea un objeto _DappPOSCode_ con el parametro url del método.
```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    if Dapp.application(app, open: url, options: options) {
       code = DappPOSCode(url: url)
    }
    return true
}
```
3. Una vez que hayas realizado la transacción desde tu servidor, notifica a la aplicación del negocio con la función **returnPayment(paymentId:)**
```swift
let paymentIdFromServer: String = "dcd7dc9c-e955-4668-ba21-45b0a6c48e72"
code.returnPayment(paymentId: paymentIdFromServer)
```
## LICENCIA
[MIT](../../LICENSE.txt)
