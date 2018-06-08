//
// Created by jordhan leoture on 26/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

public class Promise<ComputableType> {
  public typealias ResolveClosure = () throws -> ComputableType

  public let future: Future<ComputableType>
  private let closure: ThreadSafe<ResolveClosure?>
  private let semaphore: DispatchSemaphore

  public init(qos: DispatchQoS = .default) {
    let semaphore = DispatchSemaphore(value: 0)
    self.semaphore = semaphore

    let closure: ThreadSafe<ResolveClosure?> = ThreadSafe(nil)
    self.closure = closure
    self.closure.onChange { _, _ in semaphore.signal() }

    self.future = Future<ComputableType>(qos: qos) {
      semaphore.wait()
      guard let closure = closure.value else {
        throw FutureError.unknown
      }
      return try closure()
    }
  }

  public func resolve(_ closure: @escaping ResolveClosure) -> Future<ComputableType> {
    self.closure <- closure
    return future
  }

  public func reject(with error: NSError) -> Future<ComputableType> {
    self.closure <- { throw error }
    return future
  }
}
