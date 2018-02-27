//
// Created by jordhan leoture on 31/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

public enum Result<Type> {
  case success(Type)
  case failure(Error)
}
