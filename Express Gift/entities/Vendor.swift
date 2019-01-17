//
//  Vendor.swift
//  Express Gift
//
//  Created by Admin on 1/16/19.
//  Copyright © 2019 Alfonso Sotelo. All rights reserved.
//

import UIKit

class Vendor: NSObject, Codable {
    var id: Int = 0
    var name: String = ""
    
    func getPreferedGift() -> Gift {
        return getDummyPreferedGift()
    }
    
    private func getDummyPreferedGift() -> Gift {
        return Gift.getGifts()[5]
    }
    
    static func getSelf() -> Vendor {
        return getDummyVendor()
    }
    
    private static func getDummyVendor() -> Vendor {
        let vendor = Vendor()
        vendor.id = 1
        vendor.name = "Dummy Vendor"
        return vendor
    }
}
