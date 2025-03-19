import UIKit

class AboutUsViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Properties
    
    private let themeManager = ThemeManager.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - UI Setup
    
    private func setupView() {
        view.backgroundColor = themeManager.mainBackgroundColor
        
        // 设置导航栏
        themeManager.applyThemeToNavigationBar(navigationController!.navigationBar)
        title = "About Us"
        
        // 添加滚动视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加内容视图
        contentView.addSubview(logoImageView)
        contentView.addSubview(descriptionTextView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            descriptionTextView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // 设置内容
        setupContent()
    }
    
    private func setupContent() {
        // 设置 Logo
        if let logoImage = UIImage(named: "logo") {
            logoImageView.image = logoImage
        }
        
        // 设置描述文本
        let descriptionText = """
        Serendipity Spin – The Ultimate Decision-Making Slot Game! 🎰✨

        Serendipity Spin is a unique and engaging decision-making game that brings the thrill of slot machines into your everyday choices! Whether you’re struggling to pick a travel destination, wondering what to eat, or deciding which movie to watch, let fate take control with an exciting spin of the reels.

        🎲 How to Play:
            1.    Select Your Category – Choose from various decision categories like Travel, Food, Movies, or Entertainment. You can even create custom categories tailored to your lifestyle.
            2.    Spin the Slot Machine – Watch as the reels start spinning with randomized choices displayed on them. The anticipation builds as the slot machine whirls through options, creating a true casino-like experience!
            3.    Stop & Reveal Your Decision – The reels will gradually slow down and stop at a random combination of choices. The final result will be presented as your decision—no more indecisiveness!
            4.    Lucky Bonus Feature – Land on special lucky symbols like sparkling stars or crowns to unlock bonus rounds, alternative suggestions, or even a second chance to spin.
            5.    Save & Share Your Results – Store your past decisions in the history section to track trends, and easily share your results with friends to make group decisions more fun!

        🎨 Stunning Visuals & Immersive Experience
            •    Dazzling Slot Machine Effects: Enjoy smooth animations, dynamic lighting, and high-quality sound effects that create a thrilling casino-like atmosphere.
            •    Gold & Neon-Themed Design: With a rich deep purple and black gradient background, glowing gold text, and neon highlights, Serendipity Spin delivers a luxurious and engaging user experience.
            •    Dark & Light Mode Adaptability: The UI seamlessly adjusts to match your preferred system appearance.

        📌 Key Features:

        ✅ Intelligent Randomization – A balanced algorithm ensures fair and fun decision-making.
        ✅ Custom Decision Categories – Edit and expand your decision library anytime.
        ✅ History Tracking – Revisit your past spins and results.
        ✅ Lucky Rewards & Surprises – Unlock bonus features with special symbol combinations!
        ✅ Minimalist & Intuitive UI – Designed with Apple’s UIKit framework and SF Symbols for a clean and fluid interface.

        🎰 Make Every Decision an Adventure!

        Why waste time overthinking when you can add a spark of serendipity to your life? Whether it’s a small daily choice or a fun party activity, Serendipity Spin turns every decision into an exciting game of chance! Spin the reels, trust fate, and embrace the surprises that await.

        ✨ Serendipity Spin – Your next lucky decision is just a spin away! 🎉
        """
        
        descriptionTextView.text = descriptionText
        descriptionTextView.textColor = themeManager.primaryTextColor
        descriptionTextView.backgroundColor = .clear
    }
} 
