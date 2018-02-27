//
// Created by jordhan leoture on 26/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

public class Wrapper<VariableType> {
  var value: VariableType

  public init(value: VariableType) {
    self.value = value
  }
}
