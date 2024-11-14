//
//  Car.swift
//  Carangas
//
//  Created by Eduardo Frederico on 13/11/24.
//  Copyright © 2024 Eric Brito. All rights reserved.
//

import Foundation

class Car: Codable {
    
    var _id: String
    var brand: String
    var gasType: Int
    var name: String
    var price: Double
    
    var gas: String {
        switch gasType {
        case 0: 
            return "Flex Fuel"
        case 1:
            return "Etanol"
        default: 
            return "Gasolina"
        }
    }
}
