//
// Created by jordhan leoture on 30/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

public enum FutureError: Error {
  case rejectionError(with: NSError)
  case unknown
}

extension FutureError: Equatable {
  public static func ==(lhs: FutureError, rhs: FutureError) -> Bool {
    switch (lhs, rhs) {
    case let (.rejectionError(with:error1), .rejectionError(with:error2)): return error1 == error2
    case (.unknown, .unknown): return true
    default: return false
    }
  }
}
