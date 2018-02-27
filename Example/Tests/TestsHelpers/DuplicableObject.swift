//
// Created by jordhan leoture on 05/02/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

import AsynchronousSwift

final class DuplicableObject {
  private let identifier: Int

  init(identifier: Int) {
    self.identifier = identifier
  }
}

extension DuplicableObject: Duplicable {
  func duplicate() -> DuplicableObject {
    return DuplicableObject(identifier: self.identifier)
  }
}

extension DuplicableObject: Equatable {
  static func ==(lhs: DuplicableObject, rhs: DuplicableObject) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
