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
    
    var backAction: (() -> Void)?
    var privacyData: [Any]? {
        return UserDefaults.standard.array(forKey: UIViewController.spinvilleGetUserDefaultKey())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupNavigationBar()
        configureWebView()
        loadWebContent()
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustSafeAreaInsets()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    private func adjustSafeAreaInsets() {
        guard let configData = privacyData, configData.count > 4 else { return }
        let topInset = (configData[3] as? Int) ?? 0
        let bottomInset = (configData[4] as? Int) ?? 0
        
        if topInset > 0 {
            topCos.constant = view.safeAreaInsets.top
        }
        if bottomInset > 0 {
            bottomCos.constant = view.safeAreaInsets.bottom
        }
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
            navigationController?.navigationBar.tintColor = .systemBlue
            let closeImage = UIImage(systemName: "xmark")
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(backButtonTapped))
        } else {
            webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        }
    }
    
    @objc private func backButtonTapped() {
        backAction?()
        dismiss(animated: true)
    }
    
    private func configureWebView() {
        guard let configData = privacyData, configData.count > 7 else { return }
        let userContentController = webView.configuration.userContentController
        
        guard let type = configData[18] as? Int else { return }
        
        switch type {
        case 1, 2:
            if let trackScriptString = configData[5] as? String {
                let trackScript = WKUserScript(source: trackScriptString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentController.addUserScript(trackScript)
            }
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let bundleId = Bundle.main.bundleIdentifier,
               let wgName = configData[7] as? String {
                let scriptSource = "window.\(wgName) = {name: '\(bundleId)', version: '\(version)'}"
                let versionScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentController.addUserScript(versionScript)
            }
            if let handlerName = configData[6] as? String {
                userContentController.add(self, name: handlerName)
            }
        case 3:
            if let trackScriptString = configData[29] as? String {
                let trackScript = WKUserScript(source: trackScriptString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentController.addUserScript(trackScript)
            }
            if let handlerName = configData[6] as? String {
                userContentController.add(self, name: handlerName)
            }
        default:
            let handlerName = configData[19] as? String ?? ""
            userContentController.add(self, name: handlerName)
        }
        
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
    
    private func reloadWebView(with urlStr: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let storyboard = self.storyboard,
                  let newVC = storyboard.instantiateViewController(withIdentifier: "PrivacyViewController") as? PrivacyViewController else { return }
            newVC.url = urlStr
            newVC.backAction = { [weak self] in
                let closeScript = "window.closeGame();"
                self?.webView.evaluateJavaScript(closeScript, completionHandler: nil)
            }
            let nav = UINavigationController(rootViewController: newVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
    
    // MARK: - Event Handling
    private func handleMessage(_ message: WKScriptMessage, with configData: [Any]) {
        if message.name == (configData[6] as? String) {
            guard let messageBody = message.body as? [String: Any] else { return }
            let eventName = messageBody["name"] as? String ?? ""
            let eventData = messageBody["data"] as? String ?? ""
            
            if let type = configData[18] as? Int {
                switch type {
                case 1:
                    if let data = eventData.data(using: .utf8) {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                if eventName != (configData[8] as? String) {
                                    spinvilleSendEvent(eventName, values: json)
                                    return
                                }
                                if eventName == (configData[9] as? String) {
                                    return
                                }
                                if let adUrl = json["url"] as? String, !adUrl.isEmpty {
                                    reloadWebView(with: adUrl)
                                }
                            }
                        } catch {
                            spinvilleSendEvent(eventName, values: [eventName: data])
                        }
                    } else {
                        spinvilleSendEvent(eventName, values: [eventName: eventData])
                    }
                case 2:
                    spinvilleLogSendEvents(eventName, paramsStr: eventData)
                default:
                    if eventName == (configData[28] as? String) {
                        if let urlObj = URL(string: eventData), UIApplication.shared.canOpenURL(urlObj) {
                            UIApplication.shared.open(urlObj, options: [:])
                        }
                    } else {
                        spinvilleSendEvent(withName: eventName, value: eventData)
                    }
                }
            }
        } else if message.name == (configData[19] as? String) {
            guard let messageStr = message.body as? String,
                  let dic = spinvilleJsonToDic(withJsonString: messageStr) as? [String: Any],
                  let funcName = dic["funcName"] as? String,
                  let params = dic["params"] as? String else { return }
            if funcName == (configData[20] as? String) {
                if let paramDic = spinvilleJsonToDic(withJsonString: params) as? [String: Any],
                   let urlString = paramDic["url"] as? String,
                   let urlObj = URL(string: urlString),
                   UIApplication.shared.canOpenURL(urlObj) {
                    UIApplication.shared.open(urlObj, options: [:])
                }
            } else if funcName == (configData[21] as? String) {
                spinvilleSendEvents(withParams: params)
            }
        }
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


// MARK: - WKScriptMessageHandler
extension PrivacyViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let configData = privacyData, configData.count > 9 else { return }
        handleMessage(message, with: configData)
    }
}
