import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    private init() {}
    
    // MARK: - 颜色定义
    
    // 背景色
    let mainBackgroundColor = UIColor(red: 0.18, green: 0.0, blue: 0.24, alpha: 1.0) // #2E003E
    let secondaryBackgroundColor = UIColor.black // #000000
    
    // 创建背景渐变
    func createBackgroundGradient(for view: UIView) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [mainBackgroundColor.cgColor, secondaryBackgroundColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        return gradientLayer
    }
    
    // 文字颜色
    let primaryTextColor = UIColor.white // #FFFFFF
    let accentTextColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // #FFD700 (金色)
    let secondaryTextColor = UIColor(red: 0.69, green: 0.69, blue: 0.69, alpha: 1.0) // #B0B0B0 (浅灰色)
    
    // 按钮颜色
    let primaryButtonColor = UIColor(red: 0.12, green: 0.56, blue: 1.0, alpha: 1.0) // #1E90FF (金属蓝)
    let accentButtonColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // #FFD700 (金色)
    let specialButtonColor = UIColor(red: 1.0, green: 0.75, blue: 0.03, alpha: 1.0) // #FFC107 (系统黄色)
    
    // 界面元素颜色
    let borderColor = UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0) // #3A3A3A (深灰色)
    
    // MARK: - 应用主题到UI组件
    
    // 应用到导航栏
    func applyThemeToNavigationBar(_ navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = mainBackgroundColor
        appearance.titleTextAttributes = [.foregroundColor: primaryTextColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: primaryTextColor]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        
        navigationBar.tintColor = accentTextColor
    }
    
    // 应用到标签栏
    func applyThemeToTabBar(_ tabBar: UITabBar) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = mainBackgroundColor
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = secondaryTextColor
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: secondaryTextColor]
        itemAppearance.selected.iconColor = primaryButtonColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: primaryButtonColor]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    // 应用到按钮
    func styleButton(_ button: UIButton, style: ButtonStyle = .primary) {
        switch style {
        case .primary:
            button.backgroundColor = primaryButtonColor
            button.tintColor = primaryTextColor
        case .accent:
            button.backgroundColor = accentButtonColor
            button.tintColor = primaryTextColor
        case .special:
            button.backgroundColor = specialButtonColor
            button.tintColor = primaryTextColor
        }
        
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    }
    
    // 应用到视图
    func styleCard(_ view: UIView) {
        view.backgroundColor = mainBackgroundColor.withAlphaComponent(0.7)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = accentButtonColor.withAlphaComponent(0.3).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.3
    }
    
    // 按钮样式枚举
    enum ButtonStyle {
        case primary // 主要按钮 - 金属蓝
        case accent  // 强调按钮 - 金色
        case special // 特殊按钮 - 系统黄色
    }
    
    // 应用主题到整个应用
    func applyThemeToApplication() {
        // 应用到全局导航栏
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = mainBackgroundColor
        navBarAppearance.titleTextAttributes = [.foregroundColor: primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: primaryTextColor]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = accentTextColor
        
        // 应用到全局标签栏
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = mainBackgroundColor
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = secondaryTextColor
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: secondaryTextColor]
        itemAppearance.selected.iconColor = primaryButtonColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: primaryButtonColor]
        
        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        tabBarAppearance.inlineLayoutAppearance = itemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
} 