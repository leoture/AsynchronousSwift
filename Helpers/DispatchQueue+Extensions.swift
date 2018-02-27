//
// Created by jordhan leoture on 28/01/2018.
// Copyright (c) 2018 jordhan leoture. All rights reserved.
//

import Foundation

extension DispatchQueue {
  static var currentQueueLabel: String {
    return String(cString: __dispatch_queue_get_label(nil))
  }
}
