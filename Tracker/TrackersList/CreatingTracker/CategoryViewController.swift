import UIKit

//struct MockTrackers {
//    static let shared = MockTrackers()
//    let categories = [
//        TrackerCategory(
//            name: "Спорт",
//            trackers: [])
//    ]
//}

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(name: String)
}

//protocol CategoryViewModelProtocol: AnyObject {
//    func countCategories() -> Int
//}

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
    
//    private let mockTrackers = MockTrackers.shared
    private let categoryCellIdentifier = "dayOfWeek"
    
    private var viewModel: CategoryViewModel?
    
//    private var categories: [TrackerCategory] = []
    
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
               let index = viewModel?.getCategoryIndex(for: name) {
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
//        categories = mockTrackers.categories
//        if let selectedCategoryName {
//            selectedCategoryIndex = categories.firstIndex(where: { $0.name == selectedCategoryName })
//        }
        bind()
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
        let categoryEditorVC = CategoryEditorViewController(.creating)
        categoryEditorVC.delegate = self
        navigationController?.pushViewController(categoryEditorVC, animated: true)
    }
    
    private func editCategory(at indexPath: IndexPath) {
        guard
            let category = viewModel?.getCategoryName(for: indexPath)
        else { return }
        let categoryEditorVC = CategoryEditorViewController(.editing, oldName: category)
        categoryEditorVC.delegate = self
        navigationController?.pushViewController(categoryEditorVC, animated: true)
    }
    
    func initialize(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    func bind() {
        viewModel?.onCategoriesUpdated = { [weak self] in
//            guard let self else { return }
//            if let name = self.selectedCategoryName,
//               let index = self.viewModel?.getCategoryIndex(for: name) {
//                self.selectedCategoryIndex = index
//            }
            
            self?.categoryTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        categories.count
        viewModel?.countCategories() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryCellIdentifier, for: indexPath)
        guard
            let categoriesAmount = viewModel?.countCategories(),
            categoriesAmount > 0
        else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.backgroundColor = .tBackground
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        switch indexPath.row {
        case 0: cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case categoriesAmount - 1: cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default: cell.layer.maskedCorners = []
        }
        
//        cell.textLabel?.text = categories[indexPath.row].name
        cell.textLabel?.text = viewModel?.getCategoryName(for: indexPath)
        
        let selectedCategoryImageView = UIImageView(image: UIImage(named: "selectTick"))
        let isSelected = indexPath.row == selectedCategoryIndex
        cell.accessoryView = isSelected ? selectedCategoryImageView : nil
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel else { return }
        
        selectedCategoryIndex = indexPath.row
        let categoryName = viewModel.getCategoryName(for: indexPath)
        selectedCategoryName = categoryName
        
        delegate?.didSelectCategory(name: categoryName)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { actions in
            UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.editCategory(at: indexPath)
                },
                UIAction(
                    title: "Удалить",
                    attributes: .destructive
                ) { [weak self] _ in
                    self?.viewModel?.deleteCategory(at: indexPath.row)
                    if self?.selectedCategoryIndex == indexPath.row {
                        self?.selectedCategoryIndex = nil
                    }
                    
                    DispatchQueue.main.async {
                        self?.categoryTableView.reloadData()
                    }
                }
            ])
        })
    }
}

// MARK: - CategoryEditViewControllerDelegate

extension CategoryViewController: CategoryEditorViewControllerDelegate {
    func didEditedNameForCategory(oldName: String, newName: String) {
        viewModel?.editCategory(oldName: oldName, newName: newName)
        navigationController?.popViewController(animated: true)
    }
    
    func didSetNameForNewCategory(name: String) {
        viewModel?.addCategory(name: name)
        navigationController?.popViewController(animated: true)
    }
}


