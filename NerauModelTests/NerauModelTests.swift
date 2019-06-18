//
//  NerauModelTests.swift
//  NerauModelTests
//
//  Created by Benedikt Terhechte on 18.06.19.
//  Copyright © 2019 Benedikt Terhechte. All rights reserved.
//

import XCTest
@testable import NerauModel

class NerauModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let r = TrainingLogic.calculateMap(from: [
            (CGPoint(x: 0.5, y: 0.5), 1.0),
            (CGPoint(x: 1.5, y: 1.5), 3.0),
            (CGPoint(x: 2.5, y: 2.5), 5.0),
            (CGPoint(x: 3.5, y: 3.5), 7.0),
            (CGPoint(x: 4.5, y: 4.5), 9.0),
            ], canvas: CGSize(width: 32, height: 32))
        print(r)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
