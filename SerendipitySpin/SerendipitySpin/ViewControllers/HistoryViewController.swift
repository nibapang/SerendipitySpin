import UIKit

class HistoryViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let emptyStateLabel = UILabel()
    private let backgroundGradientLayer = CAGradientLayer()
    
    // MARK: - Properties
    
    private let dataManager = DataManager.shared
    private var historyItems: [Decision] = []
    private let themeManager = ThemeManager.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
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
        title = "History"
        
        // 添加清空按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(clearAllButtonTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = themeManager.accentTextColor
        
        // 设置表格视图
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = themeManager.borderColor
        
        // 设置表格视图外观
        let headerFooterAppearance = UITableViewHeaderFooterView.appearance()
        headerFooterAppearance.tintColor = themeManager.mainBackgroundColor
        
        view.addSubview(tableView)
        
        // 设置空状态标签
        emptyStateLabel.text = "No history found. Make some decisions first."
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = themeManager.secondaryTextColor
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 注册单元格
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - Data Operations
    
    private func loadData() {
        historyItems = dataManager.getHistory().sorted { $0.date > $1.date }
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !historyItems.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !historyItems.isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func clearAllButtonTapped() {
        let alertController = UIAlertController(
            title: "Clear History",
            message: "Are you sure you want to clear all history? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.dataManager.clearHistory()
            self?.loadData()
        })
        
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let historyItem = historyItems[indexPath.row]
        
        // 设置单元格样式
        cell.backgroundColor = themeManager.mainBackgroundColor.withAlphaComponent(0.5)
        
        var content = cell.defaultContentConfiguration()
        content.text = historyItem.title
        content.textProperties.color = themeManager.primaryTextColor
        
        // 使用合适的图标
        var iconName = "doc.text.fill"
        for category in DecisionCategory.allCases {
            if category.rawValue == historyItem.category {
                iconName = category.icon
                break
            }
        }
        content.image = UIImage(systemName: iconName)
        content.imageProperties.tintColor = themeManager.accentTextColor
        
        // 添加详细信息和日期
        var secondaryText = historyItem.category
        if let details = historyItem.details, !details.isEmpty {
            secondaryText += " - \(details)"
        }
        
        // 格式化日期
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        secondaryText += "\n\(dateFormatter.string(from: historyItem.date))"
        
        content.secondaryText = secondaryText
        content.secondaryTextProperties.color = themeManager.secondaryTextColor
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12)
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.tintColor = themeManager.primaryButtonColor
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 显示详情
        let historyItem = historyItems[indexPath.row]
        
        // 创建结果查看页面
        let resultVC = ResultViewController()
        resultVC.decision = historyItem
        resultVC.isLuckyResult = false
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 删除历史记录
            let historyItem = historyItems[indexPath.row]
            dataManager.deleteHistoryItem(withID: historyItem.id)
            
            // 刷新数据
            loadData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return historyItems.isEmpty ? nil : "Previous Decisions"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = themeManager.accentTextColor
            headerView.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            headerView.contentView.backgroundColor = themeManager.mainBackgroundColor.withAlphaComponent(0.8)
        }
    }
} 