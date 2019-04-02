//
//  SouthernSalesTests.swift
//  SouthernSalesTests
//
//  Created by Thomas Manu on 11/11/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import SouthernSales
import Firebase

class SouthernSalesTests: XCTestCase {
    var listingUnderTest: Listing!
    
    override func setUp() {
        listingUnderTest = Listing.init(title: "Test", price: 200, description: "Test", imageRefs: ["image1.jpg"])
    }
    
    func testThatListingIsInitializedCorrectly() {
        expect(self.listingUnderTest.title).to(equal("Test"))
        expect(self.listingUnderTest.price).to(equal(200))
        expect(self.listingUnderTest.descriptionString).to(equal("Test"))
        expect(self.listingUnderTest.imageRefs.count).to(equal(1))
        expect(self.listingUnderTest.imageRefs[0]).to(equal("image1.jpg"))
        expect(self.listingUnderTest.reference).to(beNil())
        expect(self.listingUnderTest.saved).to(beFalse())
    }
    
    func testThatChangingSavedPropertyWorks() {
        expect(self.listingUnderTest.saved).to(beFalse())
        listingUnderTest.saved = true
        expect(self.listingUnderTest.saved).to(beTrue())
    }

    override func tearDown() {
        listingUnderTest = nil
    }

}
