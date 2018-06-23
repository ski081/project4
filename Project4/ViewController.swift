//
//  ViewController.swift
//  Project4
//
//  Created by Struzinski, Mark - Mark on 6/22/18.
//  Copyright © 2018 Struzinski, Mark - Mark. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    var rows: NSStackView!
    var selectedWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let column = NSStackView(views: [makeWebView()])
        column.distribution = .fillEqually
        
        rows.addArrangedSubview(column)
    }

    @IBAction func urlEntered(_ sender: NSTextField) {
        guard let selected = selectedWebView else {
            return
        }
        
        if let url = URL(string: sender.stringValue) {
            selected.load(URLRequest(url: url))
        }
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        guard let selected = selectedWebView else {
            return
        }
        
        if sender.selectedSegment == 0 {
            selected.goBack()
        } else {
            selected.goForward()
        }
    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            let columnCount = (rows.arrangedSubviews[0] as! NSStackView).arrangedSubviews.count
            let viewArray = (0..<columnCount).map { _ in
                makeWebView()
            }
            
            let row = NSStackView(views: viewArray)
            row.distribution = .fillEqually
            rows.addArrangedSubview(row)
        } else {
            guard rows.arrangedSubviews.count > 1 else {
                return
            }
            
            guard let rowToRemove = rows.arrangedSubviews.last as? NSStackView else {
                return
            }
            
            for cell in rowToRemove.arrangedSubviews {
                cell.removeFromSuperview()
            }
            
            rows.removeArrangedSubview(rowToRemove)
        }
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            for case let row as NSStackView in rows.arrangedSubviews {
                row.addArrangedSubview(makeWebView())
            }
        } else {
            guard let firstRow = rows.arrangedSubviews.first as? NSStackView else {
                return
            }
            
            guard firstRow.arrangedSubviews.count > 1 else {
                return
            }
            
            for case let row as NSStackView in rows.arrangedSubviews {
                if let last = row.arrangedSubviews.last {
                    row.removeArrangedSubview(last)
                    last.removeFromSuperview()
                }
            }
        }
    }
    
    @IBAction func reload(_ sender: NSButton) {
        guard let webview = selectedWebView else {
            return
        }
        
        if webview.isLoading {
            webview.stopLoading()
        } else {
            webview.reload()
        }
    }
    
    func makeWebView() -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = self
        webview.wantsLayer = true
        let url = URL(string: "https://www.apple.com")!
        let urlRequest = URLRequest(url: url)
        webview.load(urlRequest)
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked(recognizer:)))
        recognizer.delegate = self
        webview.addGestureRecognizer(recognizer)
        
        if selectedWebView == nil {
            select(webView: webview)
        }
        
        return webview
    }
    
    func select(webView: WKWebView) {
        selectedWebView = webView
        selectedWebView.layer?.borderWidth = 4
        selectedWebView.layer?.borderColor = NSColor.blue.cgColor
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? ""
        }
    }
    
    @objc
    func webViewClicked(recognizer: NSClickGestureRecognizer) {
        guard let newSelectedWebView = recognizer.view as? WKWebView else {
            return
        }
        
        if let selected = selectedWebView {
            selected.layer?.borderWidth = 0
        }
        
        select(webView: newSelectedWebView)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard webView == selectedWebView else {
            return
        }
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = webView.url?.absoluteString ?? ""
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let windowController = view.window?.windowController as? WindowController else {
            return
        }
        
        windowController.reloadButton.image = NSImage(named: NSImage.Name.stopProgressTemplate)!
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let windowController = view.window?.windowController as? WindowController else {
            return
        }
        
        windowController.reloadButton.image = NSImage(named: NSImage.Name.refreshTemplate)!
    }
}

extension ViewController: NSGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        if gestureRecognizer.view == selectedWebView {
            return false
        } else {
            return true
        }
    }
}

extension ViewController: NSTouchBarDelegate {
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.enterAddress:
            let button = NSButton(title: "Enter a URL",
                                  target: self,
                                  action: #selector(selectAddressEntry))
            button.setContentHuggingPriority(NSLayoutConstraint.Priority(10),
                                             for: .horizontal)
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.view = button
            return customTouchBarItem
            
        case NSTouchBarItem.Identifier.navigation:
            let back = NSImage(named: NSImage.Name.touchBarGoBackTemplate)!
            let forward = NSImage(named: NSImage.Name.touchBarGoForwardTemplate)!
            let images = [
                back,
                forward
            ]
            let segmentedControl = NSSegmentedControl(images: images,
                                                      trackingMode: .momentary,
                                                      target: self,
                                                      action: #selector(navigationClicked(_:)))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.view = segmentedControl
            return customTouchBarItem
        case NSTouchBarItem.Identifier.sharingPicker:
            let picker = NSSharingServicePickerTouchBarItem(identifier: identifier)
            picker.delegate = self
            return picker
        case NSTouchBarItem.Identifier.adjustRows:
            let labels = [
                "Add Row",
                "Remove Row"
            ]
            let control = NSSegmentedControl(labels: labels,
                                             trackingMode: .momentaryAccelerator,
                                             target: self,
                                             action: #selector(adjustRows(_:)))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.customizationLabel = "Rows"
            customTouchBarItem.view = control
            return customTouchBarItem
        case NSTouchBarItem.Identifier.adjustColumns:
            let labels = [
                "Add Column",
                "Remove Column"
            ]
            let control = NSSegmentedControl(labels: labels,
                                             trackingMode: .momentaryAccelerator,
                                             target: self,
                                             action: #selector(adjustColumns(_:) ))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.customizationLabel = "Columns"
            customTouchBarItem.view = control
            return customTouchBarItem
        case NSTouchBarItem.Identifier.adjustGrid:
            let popover = NSPopoverTouchBarItem(identifier: identifier)
            popover.collapsedRepresentationLabel = "Grid"
            popover.customizationLabel = "Adjust Grid"
            popover.popoverTouchBar = NSTouchBar()
            popover.popoverTouchBar.delegate = self
            popover.popoverTouchBar.defaultItemIdentifiers = [
                .adjustRows,
                .adjustColumns
            ]
            return popover
        default:
            return nil
        }
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        
        let touchbar = NSTouchBar()
        touchbar.customizationIdentifier = NSTouchBar.CustomizationIdentifier("com.bobstruzsoftware.project4.")
        touchbar.delegate = self
        touchbar.defaultItemIdentifiers = [
            .navigation,
            .adjustGrid,
            .enterAddress,
            .sharingPicker
        ]
        
        touchbar.principalItemIdentifier = .enterAddress
        touchbar.customizationAllowedItemIdentifiers = [
            .sharingPicker,
            .adjustGrid,
            .adjustGrid,
            .adjustRows
        ]
        
        touchbar.customizationRequiredItemIdentifiers = [
            .enterAddress
        ]
        
        return touchbar
    }
    
    @objc
    func selectAddressEntry() {
        guard let windowController = view.window?.windowController as? WindowController else {
            return
        }
        
        windowController.window?.makeFirstResponder(windowController.addressEntry)
    }
}

extension ViewController: NSSharingServicePickerTouchBarItemDelegate {
    @available(OSX 10.12.2, *)
    func items(for pickerTouchBarItem: NSSharingServicePickerTouchBarItem) -> [Any] {
        guard let webview = selectedWebView else {
            return []
        }
        
        guard let url = webview.url?.absoluteString else {
            return []
        }
        
        return [url]
    }
}

extension NSTouchBarItem.Identifier {
    static let navigation = NSTouchBarItem.Identifier("com.bobstruzsoftware.project4.navigation")
    static let enterAddress = NSTouchBarItem.Identifier("com.bobstruzsoftware.project4.enterAddress")
    static let sharingPicker = NSTouchBarItem.Identifier("com.bobstruzsoftware.project4.sharingPicker")
    static let adjustGrid = NSTouchBarItem.Identifier("com.bobstruzsoftware.project4.adjustGrid")
    static let adjustRows = NSTouchBarItem.Identifier("com.bobstruzsoftware.project4.adjustRows")
    static let adjustColumns = NSTouchBarItem.Identifier("com.bobstruzsoftware.project4.adjustColumns")
}
