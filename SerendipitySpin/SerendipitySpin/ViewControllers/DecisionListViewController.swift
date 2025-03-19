import UIKit

class DecisionListViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    private let backgroundGradientLayer = CAGradientLayer()
    
    // MARK: - Properties
    
    private let category: DecisionCategory
    private let dataManager = DataManager.shared
    private var decisions: [Decision] = []
    private let themeManager = ThemeManager.shared
    
    // MARK: - Initialization
    
    init(category: DecisionCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
        title = "\(category.rawValue) Decisions"
        
        // 设置导航栏右侧添加按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = themeManager.accentTextColor
        
        // 设置表格视图
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = themeManager.borderColor
        view.addSubview(tableView)
        
        // 设置空状态标签
        emptyStateLabel.text = "No decisions found. Tap + to add."
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
        decisions = dataManager.getDecisions(for: category)
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !decisions.isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        let alertController = UIAlertController(title: "Add Decision", message: "Enter details for new decision", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Title"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Details (optional)"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let titleField = alertController.textFields?.first,
                  let detailsField = alertController.textFields?.last,
                  let title = titleField.text, !title.isEmpty else {
                return
            }
            
            let details = detailsField.text
            
            // 创建新决策
            let newDecision = Decision(title: title, category: self.category.rawValue, details: details)
            self.dataManager.saveDecision(newDecision)
            
            // 刷新数据
            self.loadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension DecisionListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decisions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let decision = decisions[indexPath.row]
        
        // 设置单元格样式
        cell.backgroundColor = themeManager.mainBackgroundColor.withAlphaComponent(0.5)
        
        var content = cell.defaultContentConfiguration()
        content.text = decision.title
        content.textProperties.color = themeManager.primaryTextColor
        content.secondaryText = decision.details
        content.secondaryTextProperties.color = themeManager.secondaryTextColor
        content.image = UIImage(systemName: category.icon)
        content.imageProperties.tintColor = themeManager.accentTextColor
        
        cell.contentConfiguration = content
        cell.tintColor = themeManager.primaryButtonColor
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DecisionListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 编辑决策
        let decision = decisions[indexPath.row]
        
        let alertController = UIAlertController(title: "Edit Decision", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Title"
            textField.text = decision.title
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Details (optional)"
            textField.text = decision.details
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let titleField = alertController.textFields?.first,
                  let detailsField = alertController.textFields?.last,
                  let title = titleField.text, !title.isEmpty else {
                return
            }
            
            // 删除旧决策
            self.dataManager.deleteDecision(withID: decision.id)
            
            // 创建新决策
            let newDecision = Decision(title: title, category: self.category.rawValue, details: detailsField.text)
            self.dataManager.saveDecision(newDecision)
            
            // 刷新数据
            self.loadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 删除决策
            let decision = decisions[indexPath.row]
            dataManager.deleteDecision(withID: decision.id)
            
            // 刷新数据
            loadData()
        }
    }
} 