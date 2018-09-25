//
//  WebViewController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: BaseViewController {
    
    var urlString: String
    var finish: (() -> Void)?
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.progressTintColor = UIColor.xpNavBlue()
        view.trackTintColor = .white
        return view
    } ()
    
    private var displayLink: CADisplayLink?
    
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var webViewTopConstraint: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(webView)
        webView.align(.left)
        webView.align(.right)
        webView.align(.bottom)
        webViewTopConstraint = webView.align(.top, inset: UIScreen.navBarHeight())
        view.addSubview(progressView)
        progressView.constrain(height: 2)
        progressView.align(.top, to: webView)
        progressView.align(.left)
        progressView.align(.right)
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
            webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        }        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "title")
        displayLink?.invalidate()
        finish?()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let title = change?[NSKeyValueChangeKey.newKey] as? String {
                navigationItem.title = "来自" + title
            }
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(1, animated: true)
        displayLink?.invalidate()
        displayLink = nil
        UIView.animate(withDuration: 0.25, delay: 0.5, options: [], animations: {
            self.progressView.alpha = 0
        }, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.alpha = 1
        progressView.setProgress(0, animated: false)
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .current, forMode: .commonModes)
    }
    
    @objc private func updateProgress() {
        if progressView.progress >= 0.9 {
            displayLink?.invalidate()
            displayLink = nil
            return
        }
        progressView.setProgress(progressView.progress + 0.0025, animated: true)
    }
}

