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
            Beans (8oz Can): $1.99
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
            Beans (8oz Can): $1.99
            Pencil: $0.99
            Granols Bars (Box, 8ct): $4.99
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
            Beans (8oz Can): $1.99
            Beans (8oz Can): $1.99
            Beans (8oz Can): $0.00
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
            Steak: $10.78
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
            Steak: $10.78
            Pencil: $0.99
            ------------------
            TOTAL: $11.77
            """
        XCTAssertEqual(receipt.output(), expectedReceipt)
    }
}
