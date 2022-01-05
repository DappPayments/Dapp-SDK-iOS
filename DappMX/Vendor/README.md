# Dapp Vendor SDK for iOS
Este SDK esta pensado para las aplicaciones de negocios con ventas presenciales. Cuenta con dos funciones principales:
- Leer códigos QR Request to Pay integrados al ambiente Dapp.
- Generar y monitorear el estado de códigos Dapp QR POS.

## INSTALACIÓN
Recomendamos utilizar CocoaPods para integrar Dapp Vendor SDK
```ruby
platform :ios, '11.0'
pod 'DappVendor', '~> 2.5.0'
```
De forma estándar el SDK monitorea el estado de los códigos QR POS vía peticiones HTTP.  Existe una versión alternativa que sigue el estado del código QR a través de WebSockets con ayuda de la librería [Starscream](https://github.com/daltoniam/Starscream/). Si deseas utilizar esta versión incluye esta línea en  lugar de la anterior:
```ruby
pod 'DappVendor/Socket', '~> 2.4.0'
```
## CONFIGURACIÓN
1. Agrega la siguiente instrucción de importación: 
```swift
import DappVendor
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

1. Adopta el protocolo **DappPOSCodeDelegate** e implementa sus métodos para recibir información asociada al código QR.
```swift
class ViewController: UIViewController, DappPOSCodeDelegate {

    //MARK: - DappPOSCodeDelegate
    func dappCode(_ dappCode: DappPOSCode, didChangeStatus status: DappPOSCodeStatus) {
        //handle results...
        switch status {
        case .created(let qrText, let img):
            break
        case .payed(let payment):
            break
        case .error(let error):
            break
        }
    }
```
2. Obten el listado de wallets que pueden pagar el código que vas a generar
```swift
var wallets = [DappWallet]()
func getDappCodeWallets() {
	DappPOSCode.getWallets { (walletsResponse, error) in
		if let wallets = walletsResponse {
			self.wallets = wallets
		}
	}
}
```
3. Una vez seleccionado el wallet, inicializa un objeto DappPOSCode y asignale un delegado
```swift
   var code: DappPOSCode!
    
    func generateDappPOSCode(amount: Double, description: String, reference: String?) {
        code = DappPOSCode(amount: amount, description: description, reference: reference, wallet: wallets[0])
        code.delegate = self
    }
```
4. Genera el código con una de las siguientes funciones:
```swift
code.create()
//or
code.createWithImage(size: CGSize(width: 200, height: 200))
```
5. Empieza a monitorear el estado de pago del código con la función _listen_
```swift
code.listen()
```
## Envía códigos POS por push notifications
El comercio puede hacer llegar el cobro al dispositivo de su cliente mediante una notificación push. 

Una vez generado el código de cobro y seleccionada la aplicación del cliente llama a la función **sendPushNotification(to: phone:)** del objeto **DappPOSCode**.
```swift
func enviarPush(code: DappPOSCode, phone: String){
    code.sendPushNotification(to: "4264766626") { (success, error) in
        if success {
            //handle success
        }
        else if let e = error {
            //handle error
            print(e.localizedDescription)
        }
    }
}
```
### Enviar cobro CoDi por push notification
En caso de que el comercio solo tenga habilitado cobros CoDi, una vez que el código QR ha sido creado, puede enviarlo a la aplicación CoDi del usuario a través de una push notification con la siguiente función.
```swift
code.sendCoDiPushNotification(to: "4264766626") { (success, error) in
    if success {
    //handle success
    }
    else if let e = error {
    //handle error
    print(e.localizedDescription)
    }
}
```
## CÓDIGOS QR REQUEST TO PAY
Los códigos QR RP, son códigos generados por usuarios, diseñados para dar permiso al negocio lector de realizar un cobro a su cuenta.

En caso de que la aplicación ya cuente con un lector de códigos QR propio, crea un objeto *DappRPCode* con el valor del código QR y llama a la función **charge(amount:description:reference:onCompletion:)** para realizar un cargo al usuario.
```swift
func codeScanned(qrTextFromScanner: String) {
    let code = DappRPCode(qrTextFromScanner)
    let amount: Double = 100
    let description: String = "Payment description"
    let reference: String = "Internal reference"
    code.charge(amount, description: description, reference: reference) { (payment, error) in
        //handle response...
    if let p = payment {
        //handle payment
        print(p.id!)
    }
    else {
        print(error!.localizedDescription)
    }
    }
}
```
## LECTOR DE CÓDIGOS QR RP

Las funciones del lector se pueden implementar de dos formas:

 - **Como view controller**:  Más rápido y sencillo. Crea un _DappRPCodeScannerViewController_ y preséntalo. Éste view controller se encarga de obtener la información de los códigos QR Dapp y de todos los aspectos relacionados con el UX.
 - **Como view** : Más flexible. Crea un _DappScannerView_ que solo se encargará de leer el código QR. Esto te permite implementar un UX que vaya más acorde con tu aplicación.

Cualquier opción que elijas, es necesario configurar el archivo **Info.plist**. Añade la propiedad [_NSCameraUsageDescription_](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW24)  junto con un valor de tipo _string_ describiendo por que tu app requiere del uso de la cámara (Por ej: "Escanea códigos QR"). Este texto se muestra al usuario cuando la app pide permiso para utilizar la cámara por primera vez.

### Integra el lector como view controller

1. Adopta el protocolo **DappRPCodeScannerViewControllerDelegate** e implementa sus métodos para recibir información del pago asociada al código QR escaneado.
```swift
import DappVendor

class ViewController: UIViewController, DappRPCodeScannerViewControllerDelegate {

    //MARK: - DappRPCodeScannerViewControllerDelegate
    func dappScannerViewController(_ viewController: DappScannerViewController, didReceivePayment payment: DappPayment) {
        //handle payment...
        viewController.dismiss(animated: true, completion: nil)
        print(payment.id!)
    }
    
    func dappScannerViewController(_ viewController: DappScannerViewController, didFailWithError error: DappError) {
        print(error.localizedDescription)
    }
```
2. Crea un objeto _DappRPCodeScannerViewController_ y asígnale un monto, descripción, referencia interna (opcional) y un delegate.
```swift
    @IBAction func scanQR(_ sender: Any) {
        let vc = DappRPCodeScannerViewController(amount: 100, description: "descripcion del pago", reference: nil)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
```
### Integra el lector como view
1. Adopta el protocolo **DappScannerViewDelegate** e implementa los métodos para recibir la lectura del código QR.
```swift
import DappVendor

class ViewController: UIViewController, DappScannerViewDelegate {

    //MARK: - DappScannerViewDelegate
    func dappScannerView(_ scannerView: DappScannerView, didScanCode code: String) {
        //handle text scanned from QR code
        scannerView.stopScanning()
        print(code)
        let code = DappRPCode(code)
    let amount: Double = 100
    let description: String = "Payment description"
    let reference: String = "Internal reference"
    code.charge(amount, description: description, reference: reference) { (payment, error) in
        //handle response...
        if let p = payment {
            //handle payment
            print(p.id!)
        }
        else {
            print(error!.localizedDescription)
        }
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
## Obten información de pagos
Puedes obtener los pagos recibidos dentro de un rango de fechas consultando la siguiente función:
```swift
DappPayment.getPayments(startDate: startDate, endDate: endDate) { payments, error in
            guard let paymentsArray = payments else {
                //handle error
                return
            }
            //handle payments
            print(paymentsArray.count)
        }
```
## LICENCIA
[MIT](../../LICENSE.txt)

