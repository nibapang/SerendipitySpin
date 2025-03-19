import UIKit

class ResultViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let cardView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let detailsLabel = UILabel()
    private let luckyBannerView = UIView()
    private let luckyIconImageView = UIImageView()
    private let luckyLabel = UILabel()
    private let buttonsStackView = UIStackView()
    private let tryAgainButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    
    // MARK: - Properties
    
    var decision: Decision!
    var isLuckyResult: Bool = false
    private let dataManager = DataManager.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        displayResult()
    }
    
    // MARK: - UI Setup
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Your Decision"
        navigationItem.hidesBackButton = true
        
        // 设置卡片视图
        setupCardView()
        view.addSubview(cardView)
        
        // 设置幸运奖励横幅
        setupLuckyBanner()
        view.addSubview(luckyBannerView)
        
        // 设置按钮容器
        setupButtonsStackView()
        view.addSubview(buttonsStackView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            luckyBannerView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
            luckyBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            luckyBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            luckyBannerView.heightAnchor.constraint(equalToConstant: 60),
            
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupCardView() {
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置图标
        let categoryName = decision.category
        var iconName = "questionmark"
        
        // 根据类别设置图标
        for category in DecisionCategory.allCases {
            if category.rawValue == categoryName {
                iconName = category.icon
                break
            }
        }
        
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconImageView)
        
        // 设置标题
        titleLabel.text = decision.title
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        // 设置详情
        detailsLabel.text = decision.details ?? ""
        detailsLabel.font = UIFont.systemFont(ofSize: 16)
        detailsLabel.textAlignment = .center
        detailsLabel.textColor = .secondaryLabel
        detailsLabel.numberOfLines = 0
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(detailsLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            detailsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            detailsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            detailsLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupLuckyBanner() {
        luckyBannerView.backgroundColor = .systemYellow
        luckyBannerView.layer.cornerRadius = 12
        luckyBannerView.translatesAutoresizingMaskIntoConstraints = false
        luckyBannerView.isHidden = !isLuckyResult
        
        // 设置幸运图标
        luckyIconImageView.image = UIImage(systemName: "sparkles")
        luckyIconImageView.contentMode = .scaleAspectFit
        luckyIconImageView.tintColor = .white
        luckyIconImageView.translatesAutoresizingMaskIntoConstraints = false
        luckyBannerView.addSubview(luckyIconImageView)
        
        // 设置幸运文本
        luckyLabel.text = "Lucky Bonus! Double the fun!"
        luckyLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        luckyLabel.textAlignment = .center
        luckyLabel.textColor = .white
        luckyLabel.translatesAutoresizingMaskIntoConstraints = false
        luckyBannerView.addSubview(luckyLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            luckyIconImageView.leadingAnchor.constraint(equalTo: luckyBannerView.leadingAnchor, constant: 16),
            luckyIconImageView.centerYAnchor.constraint(equalTo: luckyBannerView.centerYAnchor),
            luckyIconImageView.widthAnchor.constraint(equalToConstant: 24),
            luckyIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            luckyLabel.leadingAnchor.constraint(equalTo: luckyIconImageView.trailingAnchor, constant: 8),
            luckyLabel.trailingAnchor.constraint(equalTo: luckyBannerView.trailingAnchor, constant: -16),
            luckyLabel.centerYAnchor.constraint(equalTo: luckyBannerView.centerYAnchor)
        ])
    }
    
    private func setupButtonsStackView() {
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 12
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置尝试按钮
        tryAgainButton.setTitle("Try Again", for: .normal)
        tryAgainButton.setImage(UIImage(systemName: "gobackward"), for: .normal)
        tryAgainButton.backgroundColor = .systemBlue
        tryAgainButton.tintColor = .white
        tryAgainButton.layer.cornerRadius = 10
        tryAgainButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tryAgainButton.addTarget(self, action: #selector(tryAgainButtonTapped), for: .touchUpInside)
        
        // 设置保存按钮
        saveButton.setTitle("Save", for: .normal)
        saveButton.setImage(UIImage(systemName: "tray.and.arrow.down.fill"), for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 10
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // 设置分享按钮
        shareButton.setTitle("Share", for: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.backgroundColor = .systemIndigo
        shareButton.tintColor = .white
        shareButton.layer.cornerRadius = 10
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        buttonsStackView.addArrangedSubview(tryAgainButton)
        buttonsStackView.addArrangedSubview(saveButton)
        buttonsStackView.addArrangedSubview(shareButton)
    }
    
    // MARK: - Data Display
    
    private func displayResult() {
        if isLuckyResult {
            // 播放幸运音效
            SoundManager.shared.playWinSound()
            
            // 添加动画效果
            UIView.animate(withDuration: 0.3, delay: 0.5, options: [.autoreverse, .repeat, .curveEaseInOut], animations: {
                self.luckyBannerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            })
        }
    }
    
    // MARK: - Actions
    
    @objc private func tryAgainButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        dataManager.saveToHistory(decision)
        
        // 显示保存成功提示
        let alertController = UIAlertController(title: "Saved", message: "This decision has been saved to your history.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc private func shareButtonTapped() {
        // 创建分享文本
        var shareText = "My Serendipity Spin decision: \(decision.title)"
        if let details = decision.details {
            shareText += "\n\(details)"
        }
        
        if isLuckyResult {
            shareText += "\n\nI got a lucky bonus! 🎉"
        }
        
        // 创建分享活动视图控制器
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
} 