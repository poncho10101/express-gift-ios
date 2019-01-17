//
//  Gift.swift
//  Express Gift
//
//  Created by Admin on 1/16/19.
//  Copyright © 2019 Alfonso Sotelo. All rights reserved.
//

import UIKit

class Gift: NSObject, Codable {
    var id: Int = 0
    var name: String = ""
    
    static func getGifts() -> [Gift] {
        return getDummyGifts()
    }
    
    static func getGiftsFromVendor(_ vendor: Vendor) -> [Gift] {
        return getDummyGifts()
    }
    
    private static func getDummyGifts() -> [Gift] {
        let gifts = (1...15).map { (id) -> Gift in
            let gift = Gift()
            gift.id = id
            gift.name = "Gift $\(id)"
            return gift
        }
        
        return gifts
    }
}
