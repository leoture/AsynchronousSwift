//
// Created by jordhan leoture on 05/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

private let internalQueueLabel = "AsynchronousSwift.ThreadSafe"

public class ThreadSafe<VariableType> {
  fileprivate var wrapper: Wrapper<VariableType>
  private var callbacks: [(VariableType) -> Void]
  public let readOnly: ThreadSafeReadOnly<VariableType>
  public let readAndWrite: ThreadSafeReadAndWrite<VariableType>

  public init(_ variable: VariableType) {
    let internalQueue = DispatchQueue(label: internalQueueLabel, attributes: .concurrent)
    let _wrapper: Wrapper<VariableType> = Wrapper(value: variable)
    wrapper = _wrapper
    callbacks = [(VariableType) -> Void]()
    readOnly = ThreadSafeReadOnly<VariableType>(internalQueue: internalQueue, wrapper: _wrapper)
    readAndWrite = ThreadSafeReadAndWrite<VariableType>(internalQueue: internalQueue, wrapper: _wrapper)
  }

  public func unsafeValue() -> VariableType {
    return wrapper.value
  }

  public var value: VariableType {
    get {
      return readOnly.sync { $0 }
    }
    set {
      readAndWrite.async { value in
        value = newValue
        self.callbacks.forEach { $0(newValue) }
      }
    }
  }

  public func onChange(on queue: DispatchQueue = .global(), _ closure: @escaping (VariableType) -> Void) {
    callbacks.append({ value in queue.async { closure(value) } })
  }
}

infix operator <-

public func <-<VariableType>(left: ThreadSafe<VariableType>, right: VariableType) {
  left.value = right
}
