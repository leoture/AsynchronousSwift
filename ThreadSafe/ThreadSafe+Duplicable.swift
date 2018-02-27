//
// Created by jordhan leoture on 26/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

public extension ThreadSafe where VariableType: Duplicable {
  public var value: VariableType {
    return readOnly.sync { $0.duplicate() }
  }
}
