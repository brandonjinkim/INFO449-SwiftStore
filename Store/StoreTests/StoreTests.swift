//
//  StoreTests.swift
//  StoreTests
//
//  Created by Ted Neward on 2/29/24.
//

import XCTest

final class StoreTests: XCTestCase {

    var register = Register()

    override func setUpWithError() throws {
        register = Register()
    }

    override func tearDownWithError() throws { }

    func testBaseline() throws {
        XCTAssertEqual("0.1", Store().version)
        XCTAssertEqual("Hello world", Store().helloWorld())
    }
    
    func testOneItem() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199, register.subtotal())
        
        let receipt = register.total()
        XCTAssertEqual(199, receipt.total())

        let expectedReceipt = """
            Receipt:
            Beans (8oz Can): $1.99 Discounted: No
            ------------------
            TOTAL: $1.99
            """
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    func testThreeSameItems() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199 * 3, register.subtotal())
    }
    
    func testThreeDifferentItems() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199, register.subtotal())
        register.scan(Item(name: "Pencil", priceEach: 99))
        XCTAssertEqual(298, register.subtotal())
        register.scan(Item(name: "Granols Bars (Box, 8ct)", priceEach: 499))
        XCTAssertEqual(797, register.subtotal())
        
        let receipt = register.total()
        XCTAssertEqual(797, receipt.total())

        let expectedReceipt = """
            Receipt:
            Beans (8oz Can): $1.99 Discounted: No
            Pencil: $0.99 Discounted: No
            Granols Bars (Box, 8ct): $4.99 Discounted: No
            ------------------
            TOTAL: $7.97
            """
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    //TwoforOne
    func testTwoForOne() {
        register.sale(true)
                
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))

        let subtotal = register.subtotal()
        XCTAssertEqual(subtotal, 199 * 2)

        let receipt = register.total()
        
        let expectedReceipt = """
            Receipt:
            Beans (8oz Can): $1.99 Discounted: No
            Beans (8oz Can): $1.99 Discounted: No
            Beans (8oz Can): $0.00 Discounted: Yes
            ------------------
            TOTAL: $3.98
            """
        XCTAssertEqual(receipt.output(), expectedReceipt)
    
    }
    
    
    //Item by Weight
    func testItemByWeight() {
        register.scan(ItemByWeight(name: "Steak", weight: 1.2, pricePerPound: 899))
        
        let subtotal = register.subtotal()
        let subtotalTest = Int(899 * 1.2)
        XCTAssertEqual(subtotal, subtotalTest)
        
        let receipt = register.total()
        let expectedReceipt = """
            Receipt:
            Steak: $10.78 Discounted: No
            ------------------
            TOTAL: $10.78
            """
        XCTAssertEqual(receipt.output(), expectedReceipt)
    }
    
    func testWeightItemandRegularItem() {
        register.scan(ItemByWeight(name: "Steak", weight: 1.2, pricePerPound: 899))
        register.scan(Item(name: "Pencil", priceEach: 99))
        
        let subtotal = register.subtotal()
        let subtotalTest = Int(899 * 1.2) + 99
        XCTAssertEqual(subtotal, subtotalTest)
        
        let receipt = register.total()
        let expectedReceipt = """
            Receipt:
            Steak: $10.78 Discounted: No
            Pencil: $0.99 Discounted: No
            ------------------
            TOTAL: $11.77
            """
        XCTAssertEqual(receipt.output(), expectedReceipt)
    }
    
    func testApplyDiscountRegularItem() {
        let coupon = Coupon()
        
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        
        coupon.applyDiscount(register.receipt, "Beans (8oz Can)", 0.15)
        
        XCTAssertEqual(register.subtotal(), Int(Double(199) * 0.85))
    }
    
    func testApplyDiscountWeightItem() {
        let coupon = Coupon()
        
        register.scan(ItemByWeight(name: "Steak", weight: 1.2, pricePerPound: 899))
        
        coupon.applyDiscount(register.receipt, "Steak", 0.15)
        
        XCTAssertEqual(register.subtotal(), Int(Double(899) * 1.2 * 0.85))
    }
    
    func testApplyDiscountMultipleItems() {
        let coupon = Coupon()
        
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(ItemByWeight(name: "Steak", weight: 1.2, pricePerPound: 899))
        register.scan(ItemByWeight(name: "Steak", weight: 1.2, pricePerPound: 899))
        
        coupon.applyDiscount(register.receipt, "Beans (8oz Can)", 0.15)
        coupon.applyDiscount(register.receipt, "Beans (8oz Can)", 0.15)
        coupon.applyDiscount(register.receipt, "Steak", 0.15)
    
        let subtotal = register.subtotal()
        let subtotalTest = Int(Double(199) * 0.85) + Int(Double(199) * 0.85) + Int(Double(899) * 1.2 * 0.85) + Int(Double(899) * 1.2)
        XCTAssertEqual(subtotal, subtotalTest)
        
        let receipt = register.total()
        let expectedReceipt = """
            Receipt:
            Beans (8oz Can): $1.69 Discounted: Yes
            Beans (8oz Can): $1.69 Discounted: Yes
            Steak: $9.16 Discounted: Yes
            Steak: $10.78 Discounted: No
            ------------------
            TOTAL: $23.32
            """
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
}
