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
    private let shareCallback: (() -> Void)?
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
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
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ShareItem"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(shareAction(_:)), for: .touchUpInside)
        return button
    }()
    
    init(urlString: String, shareCallback: (() -> Void)? = nil) {
        self.urlString = urlString
        self.shareCallback = shareCallback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
        if shareCallback != nil { navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)}
        view.addSubview(webView)
        webView.fill(in: view, top: topLayoutGuide.length)
        view.addSubview(progressView)
        progressView.constrain(height: 2)
        progressView.align(.top, to: view, inset: UIScreen.navBarHeight())
        progressView.align(.left)
        progressView.align(.right)
        let request = URLRequest(url: URL(string: urlString)!)
        webView.load(request)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?) {
        guard let change = change else { return }
        if keyPath == "estimatedProgress" {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                progressView.setProgress(progress, animated: true);
            }
        }
        if keyPath == "title" {
            if let title = change[NSKeyValueChangeKey.newKey] as? String {
                navigationItem.title = title
            }
        }
    }
    
    @objc private func shareAction(_ sender: UIButton) {
        shareCallback?()
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
        UIView.animate(withDuration: 0.25, delay: 0.5, options: [], animations: {
            self.progressView.alpha = 0
        }, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.alpha = 1
    }
}
