//
// Created by jordhan leoture on 26/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import XCTest
import Nimble

import AsynchronousSwift

class FutureTest: XCTestCase {

  let error = NSError(domain: "myError", code: 1)

  func test_future_shouldBeExecutedOnTheCorrectQueue() {
    // Given
    let future = async(qos: .utility) { DispatchQueue.currentQueueLabel }

    // When
    let result = future.get()

    // Then
    expect(result).to(beSuccess("AsynchronousSwift.Future"))
  }

  func test_isFulfilled_shouldReturnFalse() {
    // Given
    let worker = DispatchSemaphore(value: 0)
    defer { worker.signal() }
    let future = async(qos: .utility) { worker.wait() }

    // When & Then
    expect(future.isFulfilled) == false
  }

  func test_isFulfilled_shouldReturnTrue() {
    // Given
    let future = async(qos: .utility) {}

    // When & Then
    expect(future.isFulfilled).toEventually(beTrue())
  }

  func test_isFulfilled_shouldReturnFalseAfterARejection() {
    // Given
    let future = async(qos: .utility) { throw self.error }

    // When & Then
    expect(future.isFulfilled).toEventually(beFalse())
  }

  func test_isPending_shouldReturnTrue() {
    // Given
    let worker = DispatchSemaphore(value: 0)
    defer { worker.signal() }
    let future = async(qos: .utility) { worker.wait() }

    // When & Then
    expect(future.isPending) == true
  }

  func test_isPending_shouldReturnFalseWhenFulfilled() {
    // Given
    let future = async(qos: .utility) {}

    // When & Then
    expect(future.isPending).toEventually(beFalse())
  }

  func test_isPending_shouldReturnFalseAfterRejection() {
    // Given
    let future = async(qos: .utility) { throw self.error }

    // When & Then
    expect(future.isPending).toEventually(beFalse())
  }

  func test_get_shouldReturnCorrectSuccess() {
    // Given
    let future = async(qos: .utility) { 3 }

    // When
    let result = future.get()

    // Then
    expect(result).to(beSuccess(3))
  }

  func test_get_shouldReturnCorrectRejectionError() {
    // Given
    let future = async(qos: .utility) { throw self.error }

    // When
    let result = future.get()

    // Then
    expect(result).to(beFailure(FutureError.rejectionError(with: error)))
  }

  func test_isRejected_shouldReturnFalse() {
    // Given
    let future = async(qos: .utility) { 3 }
    _ = future.get()

    // When
    let isRejected = future.isRejected

    // Then
    expect(isRejected) == false
  }

  func test_isRejected_shouldReturnTrue() {
    // Given
    let future = async(qos: .utility) { throw self.error }

    // When & Then
    expect(future.isRejected).toEventually(beTrue())
  }
}
