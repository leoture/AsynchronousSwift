//
// Created by jordhan leoture on 24/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation
import XCTest
import Nimble

import AsynchronousSwift

class FutureThenTest: XCTestCase {

  let error = NSError(domain: "myError", code: 1)

  func test_then_shouldCreateAnOtherFuture() {
    // Given
    let future = async(qos: .utility) { 3 }

    // When
    let otherFuture = future.then { "\($0)" }.then { $0 + "s" }.then { value in async { "\(value)!" } }

    // Then
    expect(otherFuture.get()).to(beSuccess("3s!"))
  }

  func test_then_shouldReturnARejectedFutureWhenAlreadyRejected() {
    // Given
    let futureRejected = async { throw NSError(domain: "error", code: 2) }
    _ = futureRejected.get()

    // When
    let future = futureRejected.then {}

    // Then
    expect(future.isRejected).toEventually(beTrue())
  }

  func test_then_shouldReturnARejectedFuture() {
    // Given
    let future = async(qos: .utility) { throw self.error }

    // When
    let subSubFuture = future.then { $0 }.then { $0 }

    //Then
    expect(subSubFuture.isRejected).toEventually(beTrue())
  }

  func test_then_shouldReturnFutureWithCorrectPreviousRejectionError() {
    // Given
    let future = async(qos: .utility) { throw self.error }

    // When
    let subSubFuture = future.then { $0 }.then { $0 }

    // Then
    expect(subSubFuture.get()).to(beFailure(FutureError.rejectionError(with: error)))
  }

  func test_then_shouldReturnCorrectRejectionError() {
    // Given
    let future = async(qos: .utility) {}

    // When
    let subSubFuture = future.then {}.then { throw self.error }

    // Then
    expect(subSubFuture.get()).to(beFailure(FutureError.rejectionError(with: error)))
  }

  func test_then_shouldReturnPendingFuture() {
    // Given
    let worker = DispatchSemaphore(value: 0)
    defer { worker.signal() }

    let future = async(qos: .utility) { worker.wait() }

    // When
    let resultFuture = future.then { async { "finish" } }

    // Then
    expect(resultFuture.isPending).toEventually(beTrue())
  }

  func test_then_shouldBeExecutedOnTheCorrectQueue() {
    // Given
    let future = async(qos: .utility) {}

    // When
    let resultFuture = future.then { DispatchQueue.currentQueueLabel }

    // Then
    expect(resultFuture.get()).to(beSuccess("AsynchronousSwift.Future"))
  }

  func test_then_shouldBeExecutedTheOnSameThread() {
    // Given
    var expectedThread: Thread?
    let future = async(qos: .utility) { expectedThread = Thread.current }

    // When
    var thread: Thread?
    _ = future.then { thread = Thread.current }.get()

    // Then
    expect(thread).to(beIdenticalTo(expectedThread))
  }

  func test_then_shouldExecutedNewFutureTheOnSameThread() {
    // Given
    var expectedThread: Thread?
    let future = async(qos: .utility) { expectedThread = Thread.current }

    // When
    var thread: Thread?
    _ = future.then { async { thread = Thread.current } }.get()

    // Then
    expect(thread).toEventually(beIdenticalTo(expectedThread))
  }
}
