//
// Created by jordhan leoture on 05/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import XCTest
import Nimble

import AsynchronousSwift

class ThreadSafeTests: XCTestCase {

  func test_unsafeValue_shouldReturnCorrectValue() {
    // Given
    let variable = NSObject()
    let threadSafe = ThreadSafe<NSObject>(variable)

    // When
    let unsafeValue = threadSafe.unsafeValue()

    // Then
    expect(unsafeValue) === variable
  }

  func test_syncWithReadOnly_shouldCallBlockWithCorrectVariable() {
    // Given
    let variable = NSObject()
    let threadSafe = ThreadSafe<NSObject>(variable)

    // When
    let result = threadSafe.readOnly.sync { $0 }

    // Then
    expect(result) === variable
  }

  func test_syncWithReadOnly_shouldCallBlockOnCorrectQueue() {
    // Given
    let threadSafe = ThreadSafe<NSObject>(NSObject())

    // When
    let result = threadSafe.readOnly.sync { _ in DispatchQueue.currentQueueLabel }

    // Then
    expect(result) == "AsynchronousSwift.ThreadSafe"
  }

  func test_asyncWithReadOnly_shouldCallBlockWithCorrectVariable() {
    // Given
    let variable = NSObject()
    let threadSafe = ThreadSafe<NSObject>(variable)

    // When
    var called: NSObject?
    threadSafe.readOnly.async { called = $0 }

    // Then
    expect(called).toEventually(beIdenticalTo(variable))
  }

  func test_asyncWithReadOnly_shouldCallBlockOnCorrectQueue() {
    // Given
    let threadSafe = ThreadSafe<NSObject>(NSObject())

    // When
    var labelQueue: String?
    threadSafe.readOnly.async { _ in labelQueue = DispatchQueue.currentQueueLabel }

    // Then
    expect(labelQueue).toEventually(equal("AsynchronousSwift.ThreadSafe"))
  }

  func test_syncWithReadAndWrite_shouldCallBlockWithCorrectVariable() {
    // Given
    let threadSafe = ThreadSafe<[Int]>([1])

    // When
    let result: [Int] = threadSafe.readAndWrite.sync { value in
      value.append(2)
      return value
    }

    // Then
    let expectedValue = [1, 2]
    expect(threadSafe.unsafeValue()) == expectedValue
    expect(result) == expectedValue
  }

  func test_syncWithReadAndWrite_shouldCallBlockOnCorrectQueue() {
    // Given
    let threadSafe = ThreadSafe<NSObject>(NSObject())

    // When
    let result = threadSafe.readAndWrite.sync { _ in DispatchQueue.currentQueueLabel }

    // Then
    expect(result) == "AsynchronousSwift.ThreadSafe"
  }

  func test_asyncWithReadAndWrite_shouldCallBlockWithCorrectVariable() {
    // Given
    let threadSafe = ThreadSafe<[Int]>([1])

    // When
    var called: [Int]?
    threadSafe.readAndWrite.async { value in
      value.append(2)
      called = value
    }

    // Then
    expect(called).toEventually(equal([1, 2]))
    expect(threadSafe.unsafeValue()).toEventually(equal([1, 2]))
  }

  func test_asyncWithReadAndWrite_shouldCallBlockOnCorrectQueue() {
    // Given
    let threadSafe = ThreadSafe<NSObject>(NSObject())

    // When
    var labelQueue: String?
    threadSafe.readAndWrite.async { _ in labelQueue = DispatchQueue.currentQueueLabel }

    // Then
    expect(labelQueue).toEventually(equal("AsynchronousSwift.ThreadSafe"))
  }

  func test_value_shouldReturnCorrectValueWhenIsDuplicable() {
    // Given
    let duplicableObject = DuplicableObject(identifier: 1)
    let threadSafe = ThreadSafe<DuplicableObject>(duplicableObject)

    // When
    let result = threadSafe.value

    // Then
    expect(result) !== duplicableObject
    expect(result) == duplicableObject
  }

  func test_value_shouldSetCorrectValueWhenIsDuplicable() {
    // Given
    let threadSafe = ThreadSafe<DuplicableObject>(DuplicableObject(identifier: 1))

    // When
    let duplicableObject = DuplicableObject(identifier: 2)
    threadSafe.value = duplicableObject

    // Then
    expect(threadSafe.unsafeValue()).toEventually(beIdenticalTo(duplicableObject))
  }

  func test_value_shouldReturnCorrectValueWhenIsNotDuplicable() {
    // Given
    let noDuplicableObject = NSMutableArray(array: [1])
    let threadSafe = ThreadSafe<NSMutableArray>(noDuplicableObject)

    // When
    let result = threadSafe.value

    // Then
    expect(result) === noDuplicableObject
    expect(result) == noDuplicableObject
  }

  func test_value_shouldSetCorrectValueWhenIsNotDuplicable() {
    // Given
    let threadSafe = ThreadSafe<NSMutableArray>(NSMutableArray(array: [1]))

    // When
    let noDuplicableObject = NSMutableArray(array: [2])
    threadSafe.value = noDuplicableObject

    // Then
    expect(threadSafe.unsafeValue()).toEventually(beIdenticalTo(noDuplicableObject))
  }

  func test_operator() {
    // Given
    let threadSafe = ThreadSafe<DuplicableObject>(DuplicableObject(identifier: 1))

    // When
    let object = DuplicableObject(identifier: 2)
    threadSafe <- object

    // Then
    expect(threadSafe.unsafeValue()).toEventually(beIdenticalTo(object))
  }

  func test_onChange_callbackShouldNotBeCalled() {
    // Given
    let threadSafe = ThreadSafe<Int>(2)

    // When
    var oldValue: Int?
    var newValue: Int?
    threadSafe.onChange(on: .global(qos: .utility)) {
      oldValue = $0
      newValue = $1
    }

    // Then
    expect(oldValue).toEventually(beNil())
    expect(newValue).toEventually(beNil())
  }

  func test_onChange_callbackShouldBeCalledOnCorrectQueueAfterChangeVariable() {
    // Given
    let queue = DispatchQueue.global(qos: .utility)
    let threadSafe = ThreadSafe<Int>(2)

    // When
    var queueLabel: String?
    threadSafe.onChange(on: queue) { _, _ in queueLabel = DispatchQueue.currentQueueLabel }
    threadSafe.value = 3

    // Then
    expect(queueLabel).toEventually(equal(queue.label))
  }

  func test_onChange_callbackShouldBeCalledOnCorrectDefaultQueueAfterChangeVariable() {
    // Given
    let queue = DispatchQueue.global()
    let threadSafe = ThreadSafe<Int>(2)

    // When
    var queueLabel: String?
    threadSafe.onChange { _, _ in queueLabel = DispatchQueue.currentQueueLabel }
    threadSafe.value = 3

    // Then
    expect(queueLabel).toEventually(equal(queue.label))
  }

  func test_onChange_callbackShouldBeCalledWithCorrectValue() {
    // Given
    let newExpectedObject = NSObject()
    let oldExpectedObject = NSObject()
    let threadSafe = ThreadSafe<NSObject>(oldExpectedObject)

    // When
    var object1: NSObject?
    var object2: NSObject?
    threadSafe.onChange {
      object1 = $0
      object2 = $1
    }
    threadSafe.value = newExpectedObject

    // Then
    expect(object1).toEventually(beIdenticalTo(oldExpectedObject))
    expect(object2).toEventually(beIdenticalTo(newExpectedObject))
  }
}
