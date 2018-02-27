//
// Created by jordhan leoture on 28/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import XCTest
import Nimble

import AsynchronousSwift

class AsyncTests: XCTestCase {

  let error = NSError(domain: "myError", code: 1)

  func test_async_shouldReturnCorrectFutureWithSuccess() {
    // Given
    let worker = DispatchGroup()
    worker.enter()

    // When
    let future: Future<Int> = async {
      worker.wait()
      return 3
    }

    // Then
    expect(future.isFulfilled) == false
    expect(future.isPending) == true
    worker.leave()
    expect(future.get()).to(beSuccess(3))
  }

  func test_async_shouldReturnCorrectFutureWithFailure() {
    // Given
    let worker = DispatchGroup()
    worker.enter()

    // When
    let future: Future<Void> = async {
      worker.wait()
      throw self.error
    }

    // Then
    expect(future.isFulfilled) == false
    expect(future.isPending) == true
    worker.leave()
    expect(future.get()).to(beFailure(FutureError.rejectionError(with: self.error)))
  }

  func test_async_shouldBeExecutedOnTheCorrectQueue() {
    // Given

    // When
    let future = async(qos: .utility) { DispatchQueue.currentQueueLabel }

    // Then
    expect(future.get()).to(beSuccess("AsynchronousSwift.Future"))
  }

  func test_async_shouldBeExecutedOnTheGlobalQueue() {
    // Given

    // When
    let future = async { DispatchQueue.currentQueueLabel }

    // Then
    expect(future.get()).to(beSuccess("AsynchronousSwift.Future"))
  }
}
