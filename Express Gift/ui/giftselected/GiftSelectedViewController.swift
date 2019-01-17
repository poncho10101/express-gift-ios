//
//  GiftSelectedViewController.swift
//  Express Gift
//
//  Created by Admin on 1/16/19.
//  Copyright © 2019 Alfonso Sotelo. All rights reserved.
//

import UIKit

class GiftSelectedViewController: BaseViewController {
    
    @IBOutlet weak var loadingContainer: UIView!
    @IBOutlet weak var giftDataContainer: UIView!
    @IBOutlet weak var lblGiftName: UILabel!
    
    var giftSelected: Gift?
    
    private var messageManager: GNSMessageManager!
    private var nearbySubscription: GNSSubscription!
    private var publication: GNSPublication?

    override func viewDidLoad() {
        super.viewDidLoad()

        messageManager = GNSMessageManager(apiKey: "AIzaSyDMGI8w9jpJWyU7KBKGBGdchhOrQVGsmaU")
        
        messageManager.subscription(messageFoundHandler: { (message) in
            print(message ?? "")
            if let message = message {
                self.notifyReceived(message)
            }
        }) { (message) in
            print(message ?? "")
        }
        
        loadDataInView()
    }
    
    func loadDataInView() {
        if let gift = giftSelected {
            loadingContainer.isHidden = true
            giftDataContainer.isHidden = false
            
            lblGiftName.text = gift.name
            
            publication = messageManager.publication(with: GNSMessage(content: "gift_selected_received".data(using: .utf8), type: "gift_received"))
        } else {
            loadingContainer.isHidden = false
            giftDataContainer.isHidden = true
            
            publication = nil
        }
    }
    
    func notifyReceived(_ message: GNSMessage) {
        switch message.type {
        case QrGenViewController.GIFT_SELECTED:
            handleGiftSelected(message.content)
            break
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
            
            giftSelected = gift
            loadDataInView()
        }
    }

}
