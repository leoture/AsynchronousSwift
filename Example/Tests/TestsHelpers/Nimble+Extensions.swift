import Foundation
import Nimble
import XCTest

import AsynchronousSwift

public func beFailure<T>() -> Predicate<Result<T>> {
  return Predicate { (actual: Expression<Result<T>>) throws -> PredicateResult in
    let message = ExpectationMessage.expectedActualValueTo("be failure")

    guard let actualValue = try actual.evaluate() else {
      return PredicateResult(status: .fail, message: message.appendedBeNilHint())
    }

    switch actualValue {
    case .failure: return PredicateResult(bool: true, message: message)
    default: return PredicateResult(bool: false, message: message)
    }
  }
}

public func beFailure<T, E: Equatable>(_ expectedError: E) -> Predicate<Result<T>> {
  return Predicate { (actual: Expression<Result<T>>) throws -> PredicateResult in
    let message = ExpectationMessage.expectedActualValueTo("be failure with \(expectedError)")

    guard let actualValue = try actual.evaluate() else {
      return PredicateResult(status: .fail, message: message.appendedBeNilHint())
    }

    switch actualValue {
    case .failure(let error as E): return PredicateResult(bool: error == expectedError, message: message)
    default: return PredicateResult(bool: false, message: message)
    }
  }
}

public func beSuccess() -> Predicate<Result<Void>> {
  return Predicate { (actual: Expression<Result<Void>>) throws -> PredicateResult in
    let message = ExpectationMessage.expectedActualValueTo("be success")

    guard let actualValue = try actual.evaluate() else {
      return PredicateResult(status: .fail, message: message.appendedBeNilHint())
    }

    switch actualValue {
    case .success: return PredicateResult(bool: true, message: message)
    default: return PredicateResult(bool: false, message: message)
    }
  }
}

public func beSuccess<T: Equatable>(_ expectedValue: T) -> Predicate<Result<T>> {
  return Predicate { (actual: Expression<Result<T>>) throws -> PredicateResult in
    let message = ExpectationMessage.expectedActualValueTo("be success with \(expectedValue)")

    guard let actualValue = try actual.evaluate() else {
      return PredicateResult(status: .fail, message: message.appendedBeNilHint())
    }

    switch actualValue {
    case .success(let value): return PredicateResult(bool: value == expectedValue, message: message)
    default: return PredicateResult(bool: false, message: message)
    }
  }
}

public func beSuccess<T: Equatable>(_ expectedValue: [T]) -> Predicate<Result<[T]>> {
  return Predicate { (actual: Expression<Result<[T]>>) throws -> PredicateResult in
    let message = ExpectationMessage.expectedActualValueTo("be success with \(expectedValue)")

    guard let actualValue = try actual.evaluate() else {
      return PredicateResult(status: .fail, message: message.appendedBeNilHint())
    }

    switch actualValue {
    case .success(let value): return PredicateResult(bool: value == expectedValue, message: message)
    default: return PredicateResult(bool: false, message: message)
    }
  }
}
