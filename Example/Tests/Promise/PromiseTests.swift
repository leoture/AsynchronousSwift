//
// Created by jordhan leoture on 26/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import XCTest
import Nimble

import AsynchronousSwift

class PromiseTests: XCTestCase {

  let error = NSError(domain: "myError", code: 1)

  func test_future_shouldReturnCorrectFuture() {
    // Given
    let promise = Promise<Int>(qos: .utility)

    // When
    let future = promise.future

    // Then
    expect(future.isFulfilled) == false
    expect(future.isRejected) == false
    expect(future.isPending) == true
  }

  func test_future_shouldBeExecutedOnTheCorrectQueue() {
    // Given
    let promise = Promise<String>(qos: .userInitiated)

    // When
    let result = promise.resolve { DispatchQueue.currentQueueLabel }.get()

    // Then
    expect(result).to(beSuccess("AsynchronousSwift.Future"))
  }

  func test_future_shouldBeExecutedOnTheCorrectDefaultQueue() {
    // Given
    let promise = Promise<String>()

    // When
    let result = promise.resolve { DispatchQueue.currentQueueLabel }.get()

    // Then
    expect(result).to(beSuccess("AsynchronousSwift.Future"))
  }

  func test_resolve_shouldReturnTheSameFuture() {
    // Given
    let promise = Promise<Void>(qos: .userInitiated)

    // When
    let future = promise.resolve({})

    // Then
    expect(future) === promise.future
  }

  func test_resolve_shouldFulfilledFuture() {
    // Given
    let promise = Promise<Int>(qos: .utility)

    // When
    let result = promise.resolve { 3 }.get()

    // Then
    expect(result).to(beSuccess(3))
  }

  func test_resolve_shouldRejectFutureWithCorrectError() {
    // Given
    let promise = Promise<Void>(qos: .utility)

    // When
    let result = promise.resolve { throw self.error }.get()

    // Then
    expect(result).to(beFailure(FutureError.rejectionError(with: error)))
  }

  func test_hasNoDealloc() {
    // Given
    let promise = Promise<Int>(qos: .utility)

    // When
    promise.resolve { 2 }.then {
      $0 + 1
    }.catch { _ in
    }.finally {}

    // Then
    assert(true)
  }

  func test_reject_shouldRejectFutureWithCorrectError() {
    // Given
    let promise = Promise<Void>(qos: .utility)

    // When
    let result = promise.reject(with: self.error).get()

    // Then
    expect(result).to(beFailure(FutureError.rejectionError(with: error)))
  }
}
