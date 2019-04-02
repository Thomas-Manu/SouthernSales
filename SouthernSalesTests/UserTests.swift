//
//  UserTests.swift
//  SouthernSalesTests
//
//  Created by Thomas Manu on 4/2/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import SouthernSales

class UserTests: XCTestCase {
    var userUnderTest: User!
    
    override func setUp() {
        userUnderTest = User.init(id: "jkehwq23Hsy", name: "Thomas Manu", email: "thomasm@southern.edu")
    }
    
    func testThatUserIsTheSame() {
        expect(self.userUnderTest.name).to(equal("Thomas Manu"))
        expect(self.userUnderTest.id).to(equal("jkehwq23Hsy"))
        expect(self.userUnderTest.email).to(equal("thomasm@southern.edu"))
    }

    override func tearDown() {
        userUnderTest = nil
    }
}
