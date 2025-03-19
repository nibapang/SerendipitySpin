import UIKit

class GameViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let reelsStackView = UIStackView()
    private var reels: [ReelView] = []
    private let controlButtonsStackView = UIStackView()
    private let startButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let backgroundGradientLayer = CAGradientLayer()
    private let reelsBackgroundImageView = UIImageView()
        
    // MARK: - Properties
    
    var selectedCategory: DecisionCategory = .travel
    private let reelCount = 3
    private var isSpinning = false
    private var reelsStoppedCount = 0
    private var categorySymbols: [String] = []
    private var luckySymbols = ["star.fill", "heart.fill", "crown.fill"]
    private var dataManager = DataManager.shared
    private let themeManager = ThemeManager.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadSymbols()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SoundManager.shared.stopAllSound()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    // MARK: - UI Setup
    
    private func setupView() {
        // 设置背景渐变
        backgroundGradientLayer.colors = [themeManager.mainBackgroundColor.cgColor, themeManager.secondaryBackgroundColor.cgColor]
        backgroundGradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        
        // 设置导航栏
        themeManager.applyThemeToNavigationBar(navigationController!.navigationBar)
        title = "\(selectedCategory.rawValue) Decision"
        
        // 设置状态标签
        statusLabel.text = "Tap 'Start' to spin the reels"
        statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        statusLabel.textAlignment = .center
        statusLabel.textColor = themeManager.primaryTextColor
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // 设置转轮背景
        setupReelsBackground()
        
        // 设置转轮容器
        setupReelsStackView()
        
        // 设置控制按钮容器
        setupControlButtonsStackView()
        view.addSubview(controlButtonsStackView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            reelsBackgroundImageView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 40),
            reelsBackgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reelsBackgroundImageView.widthAnchor.constraint(equalToConstant: 400), // 调整为400x400
            reelsBackgroundImageView.heightAnchor.constraint(equalToConstant: 400),
            
            reelsStackView.centerXAnchor.constraint(equalTo: reelsBackgroundImageView.centerXAnchor),
            reelsStackView.centerYAnchor.constraint(equalTo: reelsBackgroundImageView.centerYAnchor, constant: -15), // 向上移动5点
            reelsStackView.widthAnchor.constraint(equalToConstant: 150), // 适应三个34宽的ReelView加间距
            reelsStackView.heightAnchor.constraint(equalToConstant: 34), // 与ReelView高度相同
            
            controlButtonsStackView.topAnchor.constraint(equalTo: reelsBackgroundImageView.bottomAnchor, constant: 40),
            controlButtonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlButtonsStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupReelsBackground() {
        reelsBackgroundImageView.image = UIImage(named: "gameBg")
        reelsBackgroundImageView.contentMode = .scaleToFill
        reelsBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reelsBackgroundImageView)
        view.addSubview(reelsStackView) // 确保 reelsStackView 在背景图片上面
    }
    
    private func setupReelsStackView() {
        reelsStackView.axis = .horizontal
        reelsStackView.distribution = .fillEqually
        reelsStackView.alignment = .center
        reelsStackView.spacing = 24 // 增加间距，使总宽度为150（34*3 + 24*2 = 150）
        reelsStackView.translatesAutoresizingMaskIntoConstraints = false
        reelsStackView.backgroundColor = .clear
        
        // 创建转轮视图
        for _ in 0..<reelCount {
            let reelView = ReelView(frame: .zero)
            reelView.backgroundColor = .clear
            reelView.layer.borderWidth = 0
            reelView.layer.cornerRadius = 10
            
            reelsStackView.addArrangedSubview(reelView)
            reels.append(reelView)
            
            // 设置固定大小约束
            reelView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                reelView.widthAnchor.constraint(equalToConstant: 34),
                reelView.heightAnchor.constraint(equalToConstant: 34)
            ])
        }
    }
    
    private func setupControlButtonsStackView() {
        controlButtonsStackView.axis = .horizontal
        controlButtonsStackView.distribution = .fillEqually
        controlButtonsStackView.alignment = .center
        controlButtonsStackView.spacing = 30
        controlButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置开始按钮
        startButton.setTitle("Start", for: .normal)
        startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        themeManager.styleButton(startButton)
        startButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        // 设置停止按钮
        stopButton.setTitle("Stop", for: .normal)
        stopButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        themeManager.styleButton(stopButton, style: .special)
        stopButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        stopButton.isEnabled = false
        stopButton.alpha = 0.7  // 初始状态为禁用，降低透明度
        
        controlButtonsStackView.addArrangedSubview(startButton)
        controlButtonsStackView.addArrangedSubview(stopButton)
    }
    
    // MARK: - Data and Logic
    
    private func loadSymbols() {
        // 根据所选类别加载符号
        let categoryIcon = selectedCategory.icon
        categorySymbols = Array(repeating: categoryIcon, count: 5) + luckySymbols
        
        // 为每个转轮设置符号
        for reel in reels {
            reel.setSymbols(categorySymbols.shuffled())
            // 设置转轮中图标的颜色
            reel.symbolColor = themeManager.accentTextColor
        }
    }
    
    // MARK: - Actions
    
    @objc private func startButtonTapped() {
        guard !isSpinning else { return }
        
        isSpinning = true
        reelsStoppedCount = 0
        statusLabel.text = "Spinning..."
        
        startButton.isEnabled = false
        startButton.alpha = 0.7
        stopButton.isEnabled = true
        stopButton.alpha = 1.0
        
        // 播放开始音效
        SoundManager.shared.playSpinSound()
        
        // 开始所有转轮
        for reel in reels {
            reel.startSpinning()
        }
    }
    
    @objc private func stopButtonTapped() {
        guard isSpinning else { return }
        
        stopButton.isEnabled = false
        stopButton.alpha = 0.7
        statusLabel.text = "Stopping..."
        
        // 播放停止音效
        SoundManager.shared.playStopSound()
        
        // 依次停止转轮
        stopReelsSequentially()
    }
    
    private func stopReelsSequentially() {
        // 创建随机结果
        var finalSymbols: [String] = []
        let decisions = dataManager.getDecisions(for: selectedCategory)
        
        // 确保至少有一个决策
        guard !decisions.isEmpty else {
            // 如果没有决策，显示错误
            statusLabel.text = "No decisions available for this category"
            isSpinning = false
            startButton.isEnabled = true
            startButton.alpha = 1.0
            return
        }
        
        // 随机决策
        let randomDecision = decisions.randomElement()!
        
        // 随机停止每个转轮
        for (index, reel) in reels.enumerated() {
            // 延迟停止每个转轮
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                // 随机选择转轮最终显示的符号
                let symbols = reel.symbols
                let randomIndex = Int.random(in: 0..<symbols.count)
                reel.stopSpinning(atIndex: randomIndex)
                
                if let symbol = reel.getCurrentSymbol() {
                    finalSymbols.append(symbol)
                }
                
                // 检查是否所有转轮都已停止
                self.reelsStoppedCount += 1
                if self.reelsStoppedCount == self.reelCount {
                    // 所有转轮都已停止
                    self.handleSpinResult(finalSymbols: finalSymbols, decision: randomDecision)
                }
            }
        }
    }
    
    private func handleSpinResult(finalSymbols: [String], decision: Decision) {
        isSpinning = false
        startButton.isEnabled = true
        startButton.alpha = 1.0
        
        // 检查是否触发幸运奖励
        let isLuckyResult = finalSymbols.contains { luckySymbols.contains($0) }
        
        // 显示结果页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let resultVC = ResultViewController()
            resultVC.decision = decision
            resultVC.isLuckyResult = isLuckyResult
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
    }
} 
