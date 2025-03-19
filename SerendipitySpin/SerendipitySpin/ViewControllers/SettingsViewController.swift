import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let backgroundGradientLayer = CAGradientLayer()
    
    // MARK: - Properties
    
    private let settings = Settings.shared
    private let dataManager = DataManager.shared
    private let themeManager = ThemeManager.shared
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    
    // MARK: - Section and Row Types
    
    private enum Section: Int, CaseIterable {
        case appearance = 0
        case sound = 1
        case decisions = 2
        case about = 3
        
        var title: String {
            switch self {
            case .appearance:
                return "Appearance"
            case .sound:
                return "Sound & Animation"
            case .decisions:
                return "Decision Library"
            case .about:
                return "About"
            }
        }
    }
    
    private enum AppearanceRow: Int {
        case theme = 0
    }
    
    private enum SoundRow: Int {
        case sound = 0
        case animation = 1
    }
    
    private enum AboutRow: Int, CaseIterable {
        case privacy = 0
        case about = 1
        case version = 2
        
        var title: String {
            switch self {
            case .privacy:
                return "Privacy Policy"
            case .about:
                return "About Us"
            case .version:
                return "Version"
            }
        }
        
        var icon: String {
            switch self {
            case .privacy:
                return "hand.raised.fill"
            case .about:
                return "info.circle.fill"
            case .version:
                return "number.circle.fill"
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
        title = "Settings"
        
        // 设置表格视图
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorColor = themeManager.borderColor
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 注册单元格
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "switchCell")
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .appearance:
            return 1 // 主题设置
        case .sound:
            return 2 // 声音和动画设置
        case .decisions:
            return DecisionCategory.allCases.count // 所有决策类别
        case .about:
            return AboutRow.allCases.count // 关于部分的所有行
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
        case .appearance:
            return appearanceCell(for: indexPath)
        case .sound:
            return soundCell(for: indexPath)
        case .decisions:
            return decisionCell(for: indexPath)
        case .about:
            return aboutCell(for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) else { return nil }
        return sectionType.title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = themeManager.accentTextColor
            headerView.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            headerView.contentView.backgroundColor = themeManager.mainBackgroundColor.withAlphaComponent(0.8)
        }
    }
    
    // MARK: - Cell Configuration
    
    private func appearanceCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Theme"
        cell.accessoryType = .disclosureIndicator
        
        let isUserInterfaceStyleDark = traitCollection.userInterfaceStyle == .dark
        cell.detailTextLabel?.text = isUserInterfaceStyleDark ? "Dark" : "Light"
        
        // 设置单元格样式
        cell.backgroundColor = themeManager.mainBackgroundColor.withAlphaComponent(0.5)
        cell.textLabel?.textColor = themeManager.primaryTextColor
        cell.detailTextLabel?.textColor = themeManager.secondaryTextColor
        cell.tintColor = themeManager.primaryButtonColor
        
        // 设置图标
        let themeIcon = UIImage(systemName: "paintbrush.fill")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        imageView.image = themeIcon
        imageView.tintColor = themeManager.accentTextColor
        imageView.contentMode = .scaleAspectFit
        cell.imageView?.image = themeIcon
        cell.imageView?.tintColor = themeManager.accentTextColor
        
        return cell
    }
    
    private func soundCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let row = SoundRow(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
        cell.backgroundColor = themeManager.mainBackgroundColor.withAlphaComponent(0.5)
        
        switch row {
        case .sound:
            cell.titleLabel.text = "Sound Effects"
            cell.iconImageView.image = UIImage(systemName: "speaker.wave.2.fill")
            cell.switchControl.isOn = settings.isSoundEnabled
            cell.switchValueChanged = { [weak self] isOn in
                self?.settings.isSoundEnabled = isOn
            }
        case .animation:
            cell.titleLabel.text = "Animations"
            cell.iconImageView.image = UIImage(systemName: "arrow.2.circlepath")
            cell.switchControl.isOn = settings.isAnimationEnabled
            cell.switchValueChanged = { [weak self] isOn in
                self?.settings.isAnimationEnabled = isOn
            }
        }
        
        // 应用主题
        cell.titleLabel.textColor = themeManager.primaryTextColor
        cell.iconImageView.tintColor = themeManager.accentTextColor
        cell.switchControl.onTintColor = themeManager.primaryButtonColor
        
        return cell
    }
    
    private func decisionCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let category = DecisionCategory.allCases[indexPath.row]
        
        cell.textLabel?.text = category.rawValue
        cell.accessoryType = .disclosureIndicator
        
        // 设置单元格样式
        cell.backgroundColor = themeManager.mainBackgroundColor.withAlphaComponent(0.5)
        cell.textLabel?.textColor = themeManager.primaryTextColor
        cell.detailTextLabel?.textColor = themeManager.secondaryTextColor
        cell.tintColor = themeManager.primaryButtonColor
        
        // 设置图标
        let icon = UIImage(systemName: category.icon)
        cell.imageView?.image = icon
        cell.imageView?.tintColor = themeManager.accentTextColor
        
        // 显示该类别的决策数量
        let count = dataManager.getDecisions(for: category).count
        cell.detailTextLabel?.text = "\(count) items"
        
        return cell
    }
    
    private func aboutCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let row = AboutRow(rawValue: indexPath.row) else { 
            return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
        
        let cell: UITableViewCell
        if row == .version {
            // 为版本号创建 value1 样式的单元格
            cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
        
        // 设置单元格样式
        cell.backgroundColor = themeManager.mainBackgroundColor.withAlphaComponent(0.5)
        cell.textLabel?.textColor = themeManager.primaryTextColor
        cell.detailTextLabel?.textColor = themeManager.secondaryTextColor
        cell.tintColor = themeManager.primaryButtonColor
        
        // 设置图标
        let icon = UIImage(systemName: row.icon)
        cell.imageView?.image = icon
        cell.imageView?.tintColor = themeManager.accentTextColor
        
        // 设置标题和详细信息
        cell.textLabel?.text = row.title
        
        // 为版本行添加版本号
        if row == .version {
            cell.detailTextLabel?.text = appVersion
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.textLabel?.font = .systemFont(ofSize: 16)
            cell.detailTextLabel?.font = .systemFont(ofSize: 16)
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .appearance:
            handleAppearanceTap()
        case .sound:
            break // 已经使用开关控件处理
        case .decisions:
            handleDecisionsTap(at: indexPath)
        case .about:
            handleAboutTap(at: indexPath)
        }
    }
    
    private func handleAppearanceTap() {
        let alertController = UIAlertController(title: "Theme", message: "Theme settings are controlled by your device settings.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    private func handleDecisionsTap(at indexPath: IndexPath) {
        let category = DecisionCategory.allCases[indexPath.row]
        let decisionListVC = DecisionListViewController(category: category)
        navigationController?.pushViewController(decisionListVC, animated: true)
    }
    
    private func handleAboutTap(at indexPath: IndexPath) {
        guard let row = AboutRow(rawValue: indexPath.row) else { return }
        
        switch row {
        case .privacy:
            let privacyVC = UIViewController()
            privacyVC.title = "Privacy Policy"
            privacyVC.view.backgroundColor = themeManager.mainBackgroundColor
            // 这里添加隐私协议的具体内容
            navigationController?.pushViewController(privacyVC, animated: true)
            
        case .about:
            let aboutVC = UIViewController()
            aboutVC.title = "About Us"
            aboutVC.view.backgroundColor = themeManager.mainBackgroundColor
            // 这里添加关于我们的具体内容
            navigationController?.pushViewController(aboutVC, animated: true)
            
        case .version:
            break // 版本号不需要点击响应
        }
    }
}

// MARK: - 自定义开关单元格

class SwitchTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let switchControl = UISwitch()
    let iconImageView = UIImageView()
    
    var switchValueChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        selectionStyle = .none
        
        // 设置图标
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = ThemeManager.shared.accentTextColor
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)
        
        // 设置标题
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = ThemeManager.shared.primaryTextColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // 设置开关
        switchControl.onTintColor = ThemeManager.shared.primaryButtonColor
        switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switchControl)
        
        // 设置约束
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        switchValueChanged?(sender.isOn)
    }
} 