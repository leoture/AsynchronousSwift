//
// Created by jordhan leoture on 28/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

public func await<ComputableType>(_ future: Future<ComputableType>) throws -> ComputableType {
  switch future.get() {
  case let .success(value): return value
  case let .failure(FutureError.rejectionError(with: error)): throw error
  case let .failure(error): throw error
  }
}
