import UIKit

struct MockTrackers {
    static let shared = MockTrackers()
    let categories = [
        TrackerCategory(
            name: "Спорт",
            trackers: [])
    ]
}

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(name: String)
}

final class CategoryViewController: UIViewController {
    
    // MARK: - UI
    
    private enum Strings {
        static let navigationTitle = "Категория"
        static let addCategoryTitle = "Добавить категорию"
    }
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.addCategoryTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.tWhite, for: .normal)
        button.backgroundColor = .tBlack
        button.layer.cornerRadius = 16
        button.addTarget(self,
                         action: #selector(addCategoryButtonPressed),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var categoryTableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    
    private let mockTrackers = MockTrackers.shared
    private let categoryCellIdentifier = "dayOfWeek"
    
    private var categories: [TrackerCategory] = []
    
    private var selectedCategoryIndex: Int? {
        didSet {
            guard oldValue != selectedCategoryIndex else { return }
            
            var indexPathsToReload: [IndexPath] = []
            if let oldIndex = oldValue {
                indexPathsToReload.append(IndexPath(row: oldIndex, section: 0))
            }
            if let newIndex = selectedCategoryIndex {
                indexPathsToReload.append(IndexPath(row: newIndex, section: 0))
            }
            
            categoryTableView.reloadRows(at: indexPathsToReload, with: .none)
        }
    }
    
    private var selectedCategoryName: String? {
        didSet {
            if let name = selectedCategoryName,
               let index = categories.firstIndex(where: { $0.name == name }) {
                selectedCategoryIndex = index
            }
        }
    }
    
    weak var delegate: CategoryViewControllerDelegate?
    
    // MARK: - Init
    
    init(selectedCategoryName: String? = nil) {
        self.selectedCategoryName = selectedCategoryName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
        categories = mockTrackers.categories
        if let selectedCategoryName {
            selectedCategoryIndex = categories.firstIndex(where: { $0.name == selectedCategoryName })
        }
    }
    
    // MARK: - Methods
    
    private func setUpScreen() {
        setUpNavigationBar()
        view.backgroundColor = .tWhite
        
        [categoryTableView, addCategoryButton].forEach { view.addSubview($0) }
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: categoryCellIdentifier)
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setUpNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.title = Strings.navigationTitle
        navigationController?.navigationBar.tintColor = .tBlack
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
    
    @objc private func addCategoryButtonPressed() {
        // TODO: Реализовать логику добавления новой категории (спринт 16)
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryCellIdentifier, for: indexPath)
        
        cell.selectionStyle = .none
        cell.backgroundColor = .tBackground
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        switch indexPath.row {
        case 0: cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case categories.count - 1: cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default: cell.layer.maskedCorners = []
        }
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        let selectedCategoryImageView = UIImageView(image: UIImage(named: "selectTick"))
        let isSelected = indexPath.row == selectedCategoryIndex
        cell.accessoryView = isSelected ? selectedCategoryImageView : nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategoryIndex = indexPath.row
        let categoryName = categories[indexPath.row].name
        selectedCategoryName = categoryName
        
        delegate?.didSelectCategory(name: categoryName)
        
        navigationController?.popViewController(animated: true)
    }
}
