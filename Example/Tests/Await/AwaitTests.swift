//
// Created by jordhan leoture on 28/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import XCTest
import Nimble

import AsynchronousSwift

class AwaitTests: XCTestCase {
  func test_await_ShouldReturnCorrectValue() {
    // Given
    let future = async { 1 }

    // When
    let value = try? await(future)

    // Then
    expect(value).to(equal(1))
  }

  func test_await_ShouldThrowsCorrectError() {
    // Given
    let error = NSError(domain: "myError", code: 1)
    let future = async { throw error }

    // When & Then
    expect(try await(future)).to(throwError(error))
  }
}
