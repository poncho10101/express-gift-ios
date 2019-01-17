//
//  QrData.swift
//  Express Gift
//
//  Created by Admin on 1/16/19.
//  Copyright © 2019 Alfonso Sotelo. All rights reserved.
//

import UIKit

class QrData: NSObject, Codable {
    var id: Int = 0
    var vendor: Vendor? = nil
    var preferedGift: Gift? = nil
}
