//
//  QrGenViewController.swift
//  Express Gift
//
//  Created by Admin on 1/16/19.
//  Copyright © 2019 Alfonso Sotelo. All rights reserved.
//

import UIKit
import RxSwift

class QrGenViewController: BaseViewController {
    
    @IBOutlet weak var ivQrCode: UIImageView!
    @IBOutlet weak var lblQrId: UILabel!
    @IBOutlet weak var lblQrTimeLeft: UILabel!
    
    static let SCAN_STATUS = "scan_status"
    static let GIFT_SELECTED = "gift_selected"
    static let QR_SCANNED_AUTHORIZED = "qr_authorized"
    static let QR_SCANNED_DECLINED = "qr_declined"
    
    let QR_CODE_EXPIRE_TIME = 60
    var qrCodeImage: CIImage!
    
    private var timer = Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
    private var timerDisposable = DisposeBag()
    
    private var messageManager: GNSMessageManager!
    private var nearbySubscription: GNSSubscription!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        messageManager = GNSMessageManager(apiKey: "AIzaSyDMGI8w9jpJWyU7KBKGBGdchhOrQVGsmaU")
        
        messageManager.subscription(messageFoundHandler: { (message) in
            print(message ?? "")
            if let message = message {
                self.notifyReceived(message)
            }
        }) { (message) in
            print(message ?? "")
        }
        
        generateQRCode()
        
//        qrCodeView.generateCode("ASDFASDFSDF", foregroundColor: UIColor.green, backgroundColor: UIColor.red)
        
//        let messageManager = GNSMessageManager(apiKey: "AIzaSyDMGI8w9jpJWyU7KBKGBGdchhOrQVGsmaU")
//
//        messageManager?.subscription(messageFoundHandler: { (message) in
//            print("Found \(message)")
//        }, messageLostHandler: { (message) in
//            print("Lost \(message)")
//        })
    }
    
    func generateQRCode() {
        initTimer()
        
        let qrData = QrData()
        qrData.id = Int.random(in: 1 ... 100000)
        qrData.vendor = Vendor.getSelf()
        qrData.preferedGift = qrData.vendor?.getPreferedGift()
        
        let jsonEconder = JSONEncoder()
        guard let jsonData = try? jsonEconder.encode(qrData) else {
            print("json encode error")
            return
        }
        
        lblQrId.text = "QR Id: \(qrData.id)"
        
        let data = String(data: jsonData, encoding: .utf8)?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrCodeImage = filter.outputImage
            
            let scaleX = ivQrCode.frame.size.width / qrCodeImage.extent.size.width
            let scaleY = ivQrCode.frame.size.height / qrCodeImage.extent.size.height
            
            let transformedImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            ivQrCode.image = UIImage(ciImage: transformedImage)
            
        }
    }
    
    func initTimer() {
        timerDisposable = DisposeBag()
        timer.subscribe(onNext: { (time) in
            if time < self.QR_CODE_EXPIRE_TIME {
                self.setTimeLeft(self.QR_CODE_EXPIRE_TIME - time)
            } else {
                self.setTimeLeft(0)
                self.generateQRCode()
            }
        }).disposed(by: timerDisposable)
    }
    

    func setTimeLeft(_ seconds: Int) {
        lblQrTimeLeft.text = "QR Time Left: \(seconds) seconds"
    }
    
    func notifyReceived(_ message: GNSMessage) {
        let messageContent = String(data: message.content, encoding: .utf8)
        switch message.type {
        case QrGenViewController.SCAN_STATUS:
            handleQrAuthStatus(messageContent)
            break
        case QrGenViewController.GIFT_SELECTED:
            handleGiftSelected(message.content)
            break
        default:
            break
        }
    }
    
    func handleQrAuthStatus(_ status: String?) {
        switch status {
        case QrGenViewController.QR_SCANNED_AUTHORIZED:
            Toast.show(message: "Client authorized QR Auth.", controller: self)
            performSegue(withIdentifier: "fromQrGenToGiftSelected", sender: nil)
        case QrGenViewController.QR_SCANNED_DECLINED:
            Toast.show(message: "Client declined QR Auth.", controller: self)
        default:
            break
        }
    }
        
    func handleGiftSelected(_ giftData: Data?) {
        if let giftData = giftData {
            guard let gift = try? JSONDecoder().decode(Gift.self, from: giftData) else {
                print("JSON Gift Decode Error")
                return
            }
            performSegue(withIdentifier: "fromQrGenToGiftSelected", sender: gift)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromQrGenToGiftSelected" {
            if let destination = segue.destination as? GiftSelectedViewController,
                let gift = sender as? Gift {
                destination.giftSelected = gift
            }
        }
    }
}
