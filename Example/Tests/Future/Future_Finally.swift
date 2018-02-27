//
// Created by jordhan leoture on 24/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import XCTest
import Nimble

import AsynchronousSwift

class FutureFinallyTest: XCTestCase {

  let error = NSError(domain: "myError", code: 1)

  func test_finally_shouldBeExecutedOnTheCorrectQueue() {
    // Given
    var queueLabel: String?
    let future = async {}

    // When
    future.finally(qos: .utility) { queueLabel = DispatchQueue.currentQueueLabel }

    // Then
    expect(queueLabel).toEventually(equal("AsynchronousSwift.Future"))
  }

  func test_finally_shouldBeExecutedOnTheSameThread() {
    // Given
    let worker = DispatchSemaphore(value: 0)

    var expectedThread: Thread?
    let future = async { expectedThread = Thread.current }

    // When
    var thread: Thread?
    future.finally(qos: .utility) {
      thread = Thread.current
      worker.signal()
    }

    worker.wait()

    // Then
    expect(thread).toEventually(beIdenticalTo(expectedThread))
  }

  func test_finally_shouldBeExecutedAfterThen() {
    // Given
    var isCalled = false
    let future = async { 2 }

    // When
    future.then { $0 + 1 }.finally { isCalled = true }

    // Then
    expect(isCalled).toEventually(beTrue())
  }

  func test_finally_shouldBeExecutedAfterCatch() {
    // Given
    var isCalled = false
    let future = async {}

    // When
    future.then {
      throw self.error
    }.catch { _ in
    }.finally {
      isCalled = true
    }

    // Then
    expect(isCalled).toEventually(beTrue())
  }
}
