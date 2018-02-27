//
// Created by jordhan leoture on 26/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

public class ThreadSafeReadAndWrite<VariableType> {

  private let internalQueue: DispatchQueue
  private let wrapper: Wrapper<VariableType>

  init(internalQueue: DispatchQueue, wrapper: Wrapper<VariableType>) {
    self.internalQueue = internalQueue
    self.wrapper = wrapper
  }

  public func sync<ReturnType>(_ closure: (inout VariableType) -> ReturnType) -> ReturnType {
    return internalQueue.sync(flags: .barrier) { closure(&self.wrapper.value) }
  }

  public func async(_ closure: @escaping (inout VariableType) -> Void) {
    return internalQueue.async(flags: .barrier) { closure(&self.wrapper.value) }
  }
}
