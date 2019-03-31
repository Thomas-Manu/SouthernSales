//
//  SouthernSalesTests.swift
//  SouthernSalesTests
//
//  Created by Thomas Manu on 11/11/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import XCTest
@testable import SouthernSales
import Firebase

class SouthernSalesTests: XCTestCase {
    var listingUnderTest: Listing!
    
    override func setUp() {
        listingUnderTest = Listing.init(title: "Test", price: 200, description: "Test", imageRefs: ["image1.jpg"])
    }
    
    func testThatListingIsInitializedCorrectly() {
        XCTAssertEqual(listingUnderTest.title, "Test")
        XCTAssertEqual(listingUnderTest.price, 200)
        XCTAssertEqual(listingUnderTest.descriptionString, "Test")
        XCTAssertEqual(listingUnderTest.imageRefs.count, 1)
        XCTAssertEqual(listingUnderTest.imageRefs[0], "image1.jpg")
        XCTAssertNil(listingUnderTest.reference)
        XCTAssertFalse(listingUnderTest.saved)
    }
    
    func testThatChangingSavedPropertyWorks() {
        XCTAssertFalse(listingUnderTest.saved)
        listingUnderTest.saved = true
        XCTAssertTrue(listingUnderTest.saved)
    }

    override func tearDown() {
        listingUnderTest = nil
    }

}
