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

    override var representedObject: Any? {
        didSet {
        }
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
