//
//  PrivacyViewController.swift
//  SerendipitySpin
//
//  Created by Serendipity Spin on 2025/3/20.
//

import UIKit
@preconcurrency import WebKit

class PrivacyViewController: UIViewController {

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var bottomCos: NSLayoutConstraint!
    
    @objc var url: String?
    let defaultPrivacyUrl = "https://www.termsfeed.com/live/11a15ba9-88a2-4efb-b1df-7d7f1e652812"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupNavigationBar()
        configureWebView()
        loadWebContent()
        // Do any additional setup after loading the view.
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }

    //MARK: - Functions
    private func setupViews() {
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .black
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        indicatorView.hidesWhenStopped = true
    }

    private func setupNavigationBar() {
        if let url = url, !url.isEmpty {
        } else {
            webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        }
    }
    
    private func configureWebView() {
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    private func loadWebContent() {
        let urlString = url ?? defaultPrivacyUrl
        guard let urlObj = URL(string: urlString) else { return }
        indicatorView.startAnimating()
        let request = URLRequest(url: urlObj)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate
extension PrivacyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async { self.indicatorView.stopAnimating() }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async { self.indicatorView.stopAnimating() }
    }
}

// MARK: - WKUIDelegate
extension PrivacyViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let urlObj = navigationAction.request.url {
            UIApplication.shared.open(urlObj)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }
    }
}
