//
// Created by jordhan leoture on 24/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import XCTest
import Nimble

import AsynchronousSwift

class FutureCatchTest: XCTestCase {

  let error = NSError(domain: "myError", code: 1)

  func test_catch_shouldNotBeExecuted() {
    // Given
    let future = async {}

    // When
    var errorCaught: Error?
    _ = future.catch { errorCaught = $0 }.get()

    // Then
    expect(errorCaught).to(beNil())
  }

  func test_catch_shouldBeExecutedWithCorrectRejectionError() {
    // Given
    let future = async { throw self.error }

    // When
    var errorCaught: Error?
    _ = future.catch { errorCaught = $0 }.get()

    // Then
    expect(errorCaught as? FutureError).toEventually(equal(FutureError.rejectionError(with: error)))
  }

  func test_catch_shouldBeExecutedOnTheCorrectQueue() {
    // Given
    var queueLabel: String?
    let future = async { throw self.error }

    // When
    _ = future.catch(qos: .utility) { _ in queueLabel = DispatchQueue.currentQueueLabel }.get()

    // Then
    expect(queueLabel).toEventually(equal("AsynchronousSwift.Future"))
  }

  func test_catch_shouldBeExecutedOnTheSameThread() {
    // Given
    let worker = DispatchSemaphore(value: 0)
    var expectedThread: Thread?
    let future = async {
      worker.wait()
      expectedThread = Thread.current
      throw self.error
    }

    // When
    var thread: Thread?
    let futureCatch = future.catch(qos: .utility) { _ in thread = Thread.current }
    worker.signal()
    _ = futureCatch.get()

    // Then
    expect(thread).to(beIdenticalTo(expectedThread))
  }
}
