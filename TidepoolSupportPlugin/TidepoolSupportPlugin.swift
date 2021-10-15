//
//  TidepoolSupportPlugin
//
//  Created by Rick Pasetto on 10/11/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import os.log
import LoopKitUI
import TidepoolSupport

class TidepoolSupportPlugin: NSObject, SupportUIPlugin {
    private let log = OSLog(category: "TidepoolSupportPlugin")

    public var support: SupportUI = TidepoolSupport()

    override init() {
        super.init()
        log.default("Instantiated")
    }
    
    deinit {
        log.default("Deinitialized")
    }
}
