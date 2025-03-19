import UIKit

class ReelView: UIView {
    
    // MARK: - Properties
    
    private let reelBackground = UIView()
    private let symbolLabel = UILabel()
    private let iconImageView = UIImageView()
    
    private var timer: CADisplayLink?
    private var isSpinning = false
    private var currentSpeed: CGFloat = 20.0
    private(set) var symbols: [String] = []
    private var currentIndex = 0
    private var shouldStop = false
    private var stopPosition: Int?
    
    // 添加符号颜色属性
    var symbolColor: UIColor = .label {
        didSet {
            // 当颜色改变时更新图标颜色
            iconImageView.tintColor = symbolColor
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        
        // 设置转轮背景
        reelBackground.backgroundColor = .systemGray6
        reelBackground.layer.cornerRadius = 10
        reelBackground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(reelBackground)
        
        // 设置图标视图
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = symbolColor // 使用symbolColor设置图标颜色
        reelBackground.addSubview(iconImageView)
        
        // 约束设置
        NSLayoutConstraint.activate([
            reelBackground.topAnchor.constraint(equalTo: topAnchor),
            reelBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            reelBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            reelBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            iconImageView.centerXAnchor.constraint(equalTo: reelBackground.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: reelBackground.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalTo: reelBackground.widthAnchor, multiplier: 0.6),
            iconImageView.heightAnchor.constraint(equalTo: reelBackground.heightAnchor, multiplier: 0.6)
        ])
    }
    
    // MARK: - Public Methods
    
    func setSymbols(_ symbols: [String]) {
        self.symbols = symbols
        if !symbols.isEmpty {
            updateSymbol(symbols[0])
        }
    }
    
    func startSpinning() {
        guard !symbols.isEmpty, !isSpinning else { return }
        
        isSpinning = true
        currentSpeed = 20.0
        shouldStop = false
        stopPosition = nil
        
        // 创建动画计时器
        timer = CADisplayLink(target: self, selector: #selector(updateReel))
        timer?.add(to: .current, forMode: .common)
    }
    
    func stopSpinning(atIndex index: Int? = nil) {
        shouldStop = true
        if let index = index, index < symbols.count {
            stopPosition = index
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func updateReel() {
        if shouldStop {
            // 逐渐减速
            currentSpeed *= 0.95
            
            if currentSpeed < 0.5 {
                // 最终停止
                if let stopPosition = stopPosition {
                    currentIndex = stopPosition
                    updateSymbol(symbols[stopPosition])
                }
                
                timer?.invalidate()
                timer = nil
                isSpinning = false
                return
            }
        }
        
        // 更新符号
        currentIndex = (currentIndex + 1) % symbols.count
        updateSymbol(symbols[currentIndex])
    }
    
    private func updateSymbol(_ symbolName: String) {
        // 更新图标
        if let image = UIImage(systemName: symbolName) {
            iconImageView.image = image
            iconImageView.tintColor = symbolColor // 确保更新图标时应用当前颜色
            
            // 添加缩放动画
            if Settings.shared.isAnimationEnabled {
                UIView.animate(withDuration: 0.1, animations: {
                    self.iconImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        self.iconImageView.transform = .identity
                    }
                })
            }
        }
    }
    
    // 获取当前显示的符号
    func getCurrentSymbol() -> String? {
        return symbols.isEmpty ? nil : symbols[currentIndex]
    }
} 