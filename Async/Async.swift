//
// Created by jordhan leoture on 28/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

public func async<ComputableType>(qos: DispatchQoS = .default,
                                  _ closure: @escaping () throws -> ComputableType) -> Future<ComputableType> {
  return Future(qos: qos, closure)
}
