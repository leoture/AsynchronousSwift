//
// Created by jordhan leoture on 24/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import XCTest
import Nimble

import AsynchronousSwift

class FutureSyncTest: XCTestCase {

  let error = NSError(domain: "myError", code: 1)

  func test_sync_shouldBeCalledWithCorrectValueOnSuccess() {
    // Given
    let expectedValue = "value"
    let future = async { expectedValue }

    // When
    var result: Result<String>?
    future.sync { value in
      result = value
    }

    // Then
    expect(result).toEventually(beSuccess(expectedValue))
  }

  func test_sync_shouldBeCallWithCorrectValueOnFailure() {
    // Given
    let future = async { throw self.error }

    // When
    var result: Result<Void>?
    future.sync { value in
      result = value
    }

    // Then
    expect(result).toEventually(beFailure(FutureError.rejectionError(with: self.error)))
  }

  func test_sync_shouldReturnCorrectValue() {
    // Given
    let future = async {}

    // When
    let expectedValue = "success"
    let value = future.sync { _ in expectedValue }

    // Then
    expect(value).to(equal(expectedValue))
  }
}
