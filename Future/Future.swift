//
// Created by jordhan leoture on 26/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

private let internalQueueLabel = "AsynchronousSwift.Future"

public class Future<ComputableType> {

  private var internalQueue: DispatchQueue!
  private var computedValue: ThreadSafe<ComputableType?> = ThreadSafe(nil)
  private let semaphore = DispatchSemaphore(value: 0)
  private var rejectedError: ThreadSafe<NSError?> = ThreadSafe(nil)

  public convenience init(qos: DispatchQoS = .default, _ closure: @escaping () throws -> ComputableType) {
    self.init(on: DispatchQueue(label: internalQueueLabel, qos: qos), closure: closure)
  }

  private init(on queue: DispatchQueue, closure: @escaping () throws -> ComputableType) {
    let closure = { [weak self] in
      do {
        self?.computedValue.value = try closure()
      } catch FutureError.rejectionError(let error) {
        self?.reject(with: error)
      } catch {
        self?.reject(with: error as NSError)
      }
      self?.semaphore.signal()
    }

    self.internalQueue = queue

    if DispatchQueue.currentQueueLabel == internalQueueLabel {
      queue.sync { closure() }
    } else {
      queue.async { closure() }
    }
  }

  public var isRejected: Bool {
    return rejectedError.value != nil
  }

  private func reject(with error: NSError) {
    rejectedError <- error
  }

  public var isFulfilled: Bool {
    return computedValue.value != nil
  }

  public var isPending: Bool {
    return !isFulfilled && !isRejected
  }

  public func get() -> Result<ComputableType> {
    if let computedValue = self.computedValue.value {
      return .success(computedValue)
    }

    semaphore.wait()
    semaphore.signal()

    if isRejected {
      return .failure(FutureError.rejectionError(with: rejectedError.value!))
    }

    guard let value = computedValue.value else {
      return .failure(FutureError.unknown)
    }

    return .success(value)
  }

  private func createNextFuture<ReturnType>(qos: DispatchQoS = .default,
                                            onSuccess: @escaping (ComputableType) throws -> ReturnType,
                                            onFailure: @escaping  (Error) throws -> ReturnType) -> Future<ReturnType> {
    let queue = DispatchQueue(label: internalQueueLabel, qos: qos, target: self.internalQueue)
    return Future<ReturnType>(on: queue) {
      switch self.get() {
      case let .success(value):  return try onSuccess(value)
      case let .failure(error): return try onFailure(error)
      }
    }
  }

  public func sync<ReturnType>(_ closure: @escaping (Result<ComputableType>) -> ReturnType) -> ReturnType {
    return closure(self.get())
  }
}

extension Future {
  @discardableResult public func then(qos: DispatchQoS = .default,
                                      _ closure: @escaping (ComputableType) throws -> Void) -> Future<Void> {
    return createNextFuture(qos: qos, onSuccess: { try closure($0) }, onFailure: { throw $0 })
  }

  @discardableResult public func then<ReturnType>(qos: DispatchQoS = .default,
                                                  _ closure: @escaping (ComputableType) throws -> ReturnType) -> Future<ReturnType> {
    return createNextFuture(qos: qos, onSuccess: { try closure($0) }, onFailure: { throw $0 })
  }

  @discardableResult public func then<ReturnType>(qos: DispatchQoS = .default,
                                                  _ closure: @escaping (ComputableType) throws -> Future<ReturnType>)
          -> Future<ReturnType> {
    let onSuccess = { (value: ComputableType) -> ReturnType in
      switch try closure(value).get() {
      case let .success(value): return value
      case let .failure(error): throw error
      }
    }

    return createNextFuture(qos: qos, onSuccess: onSuccess, onFailure: { throw $0 })
  }
}

extension Future {
  @discardableResult public func `catch`(qos: DispatchQoS = .default,
                                         _ closure: @escaping (Error) -> Void) -> Future<Void> {
    return createNextFuture(qos: qos, onSuccess: { _ in }, onFailure: { closure($0) })
  }
}

extension Future {
  public func finally(qos: DispatchQoS = .default, _ closure: @escaping () -> Void) {
    internalQueue.async(qos: qos) { closure() }
  }
}
