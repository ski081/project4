//
//  WindowController.swift
//  Project4
//
//  Created by Struzinski, Mark - Mark on 6/22/18.
//  Copyright © 2018 Struzinski, Mark - Mark. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    @IBOutlet var addressEntry: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden
    }

}
