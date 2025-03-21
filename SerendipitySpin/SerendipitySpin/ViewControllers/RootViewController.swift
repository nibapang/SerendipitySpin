import UIKit
import AdjustSdk

class RootViewController: UIViewController, AdjustDelegate {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        needRecordDeviceData()
    }
    
    private func setupUI() {
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 设置背景图片
        if let backgroundImage = UIImage(named: "lanuch") {
            backgroundImageView.image = backgroundImage
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func showMainTabbar() {
        let mainTabbarVC = MainTabBarController()
        addChild(mainTabbarVC)
        mainTabbarVC.view.frame = UIScreen.main.bounds
        view.addSubview(mainTabbarVC.view)
        mainTabbarVC.didMove(toParent: self)
    }
    
    private func needRecordDeviceData() {
        guard self.needShowBannersView() else {
            showMainTabbar()
            return
        }
        postDeviceData { [weak self] adsData in
            guard let self = self else { return }
            if let adsData = adsData,
               adsData.count >= 3,
               let userDefaultKey = adsData[0] as? String,
               let nede = adsData[1] as? Int,
               let adsUrl = adsData[2] as? String,
               !adsUrl.isEmpty {
                let adtokenDic = adsData[31] as? [String: String]
                initAdjust(token: adtokenDic?["token"])
                UIViewController.setAdsUserDefaultKey(userDefaultKey)
                if nede == 0,
                   let localData = UserDefaults.standard.value(forKey: userDefaultKey) as? [Any],
                   localData.count > 2,
                   let localAdsUrl = localData[2] as? String {
                    self.showBanneradView(localAdsUrl)
                } else {
                    UserDefaults.standard.set(adsData, forKey: userDefaultKey)
                    self.showBanneradView(adsUrl)
                }
                return
            }
            self.showMainTabbar()
        }
    }

    private func postDeviceData(completion: @escaping ([Any]?) -> Void) {
        guard let url = URL(string: "https://open.skybe\(self.mainHostUrl())/open/postDeviceData") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "localizedModel": UIDevice.current.localizedModel,
            "appModel": UIDevice.current.model,
            "appKey": "d8ca4b14ef9841088ae08e196452c30c",
            "appPackageId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dataDic = jsonResponse["data"] as? [String: Any],
                       let adsData = dataDic["jsonObject"] as? [Any] {
                        completion(adsData)
                        return
                    } else {
                        print("Unexpected JSON structure:", data)
                        completion(nil)
                    }
                } catch {
                    print("Failed to parse JSON:", error)
                    completion(nil)
                }
            }
        }.resume()
    }
    
    private func initAdjust(token: String?) {
        if let token = token {
            let environment = ADJEnvironmentProduction
            let adjustConfig = ADJConfig(appToken: token, environment: environment)
            adjustConfig?.logLevel = ADJLogLevel.verbose
            adjustConfig?.delegate = self
            Adjust.initSdk(adjustConfig)
        }
    }
    
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        print("adjustAttributionChanged:")
    }
    
    func adjustEventTrackingFailed(_ eventFailureResponse: ADJEventFailure?) {
        let msg = eventFailureResponse?.message
        print("adjustEventTrackingFailed:\(msg ?? "")")
    }
    
    func adjustEventTrackingSucceeded(_ eventSuccessResponse: ADJEventSuccess?) {
        print("adjustEventTrackingSucceeded:")
    }
}
