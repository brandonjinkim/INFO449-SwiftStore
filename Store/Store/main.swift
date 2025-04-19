//
//  main.swift
//  Store
//
//  Created by Ted Neward on 2/29/24.
//

import Foundation

protocol SKU {
    var name : String { get }
    func price() -> Int
    var itemDiscount: Bool { get }
}

class Item : SKU {
    let name: String
    let priceEach: Int
    let itemDiscount: Bool
    
    init(name: String, priceEach: Int, itemDiscount: Bool = false) {
        self.name = name
        self.priceEach = priceEach
        self.itemDiscount = itemDiscount
    }
    
    func price() -> Int {
        return priceEach
    }
}

class ItemByWeight : SKU {
    let name: String
    let weight: Double
    let pricePerPound: Int
    let itemDiscount: Bool
    var priceEach: Int
    
    init(name: String, weight: Double, pricePerPound: Int, itemDiscount: Bool = false, priceEach: Int = 0) {
        self.name = name
        self.weight = weight
        self.pricePerPound = pricePerPound
        self.itemDiscount = itemDiscount
        self.priceEach = priceEach
    }
    
    func price() -> Int {
        priceEach = Int(Double(pricePerPound) * weight)
        return priceEach
    }
    
}

class Receipt {
    var itemList: [SKU] = []
    func items() -> [SKU] {
        return itemList
    }
    func add(_ item: SKU) {
        itemList.append(item)
    }
    
    func total() -> Int {
        return itemList.reduce(0) { $0 + $1.price() }
    }
    
    func output() -> String {
        var output = "Receipt:\n"
        for item in itemList {
            let priceDollars = Double(item.price()) / 100.0
            
            //"%.2f" makes the double 2 decimal points, even in the case that it equals 0
            output += "\(item.name): $\(String(format: "%.2f", priceDollars)) Discounted: \(item.itemDiscount ? "Yes" : "No")\n"
        }
        output += "------------------\n"
        let totalDollars = Double(total()) / 100.0
        output += "TOTAL: $\(totalDollars)"
        
        return output
    }
}

// Sets sale as function that receives optional boolean
// (which is set is default false in Register)
protocol PricingScheme {
    func sale(_ sale: Bool?)
    
}

class Register : PricingScheme {
    
    var receipt = Receipt()
    var twoforone : Bool = false
    //dictionary tracking items and their counts
    var itemCount: [String: Int] = [:]
    
    func sale(_ sale: Bool?) {
        if sale == true {
            twoforone = true
        }
    }
    
    func scan (_ sku: SKU) {
        
        // 2-for-1
        if (twoforone == true) {
            //"default" sets the int to 0, but doesnt
            // redeclare it as 0 every time
            itemCount[sku.name, default: 0] += 1
            
            // if there are 3 of the same item
            if itemCount[sku.name]! % 3 == 0 {
                // add item to receipt with price set as 0
                receipt.add(Item(name: sku.name, priceEach: 0, itemDiscount: true))
            }
            // if not
            else {
                // add the item as you normally would
                receipt.add(sku)
            }
        }
        else {
            receipt.add(sku)
        }
    }
    
    func subtotal() -> Int {
        return receipt.total()
    }
    
    func total() -> Receipt {
        let totalReceipt = receipt
        receipt = Receipt()
        return totalReceipt
    }
    
}

class Coupon {
    func applyDiscount(_ receipt: Receipt, _ name: String, _ discount: Double) {
        var i = 0
        while i < receipt.itemList.count {
            let item = receipt.itemList[i]
            if (item.name == name && item.itemDiscount == false) {
                let newPrice = Int(Double(item.price()) * (1.0 - discount))
                let discountedItem = Item(name: item.name, priceEach: newPrice, itemDiscount: true)
                receipt.itemList[i] = discountedItem
                break
            }
            i = i + 1
        }
    }
}

class Store {
    let version = "0.1"
    func helloWorld() -> String {
        return "Hello world"
    }
}

