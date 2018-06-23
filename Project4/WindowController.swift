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
    @IBOutlet weak var reloadButton: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden
    }

    override func cancelOperation(_ sender: Any?) {
        window?.makeFirstResponder(self.contentViewController)
    }
}
