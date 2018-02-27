//
// Created by jordhan leoture on 26/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

public class ThreadSafeReadOnly<VariableType> {

  private let internalQueue: DispatchQueue
  private let wrapper: Wrapper<VariableType>

  init(internalQueue: DispatchQueue, wrapper: Wrapper<VariableType>) {
    self.internalQueue = internalQueue
    self.wrapper = wrapper
  }

  public func sync<ReturnType>(_ closure: (VariableType) -> ReturnType) -> ReturnType {
    return internalQueue.sync { closure(self.wrapper.value) }
  }

  public func async(_ closure: @escaping (VariableType) -> Void) {
    return internalQueue.async { closure(self.wrapper.value) }
  }
}
