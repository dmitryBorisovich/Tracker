import UIKit

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
    
    private lazy var placeholder: PlaceholderView = {
        let placeholder = PlaceholderView(
            title: "Привычки и события можно объединить по смыслу"
        )
        placeholder.isHidden = true
        placeholder.isUserInteractionEnabled = false
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        return placeholder
    }()
    
    // MARK: - Properties
    
    private let categoryCellIdentifier = "cellCategory"
    
    private var viewModel: CategoryViewModel?
    
    weak var delegate: CategoryViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
    
    // MARK: - Methods
    
    private func setUpScreen() {
        setUpNavigationBar()
        view.backgroundColor = .tWhite
        
        [categoryTableView,
         addCategoryButton,
         placeholder].forEach { view.addSubview($0) }
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: categoryCellIdentifier)
        
        setUpConstraints()
        updatePlaceholder()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
    
    private func updatePlaceholder() {
        let isEmpty = viewModel?.countCategories() == 0
        placeholder.isHidden = !isEmpty
    }
    
    @objc private func addCategoryButtonPressed() {
        let categoryEditorVC = CategoryEditorViewController(.creating)
        categoryEditorVC.delegate = self
        navigationController?.pushViewController(categoryEditorVC, animated: true)
    }
    
    private func editCategory(at indexPath: IndexPath) {
        guard
            let categoryName = viewModel?.getCategoryName(for: indexPath)
        else { return }
        let categoryEditorVC = CategoryEditorViewController(
            .editing,
            index: indexPath,
            currentName: categoryName
        )
        categoryEditorVC.delegate = self
        navigationController?.pushViewController(categoryEditorVC, animated: true)
    }
    
    func initialize(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    private func bind() {
        viewModel?.onCategoriesUpdated = { [weak self] in
            self?.categoryTableView.reloadData()
            self?.updatePlaceholder()
        }
        
        viewModel?.onError = { error in
            print(error)
        }
    }
    
    private func showDeleteConfirmation(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Эта категория точно не нужна?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: "Удалить",
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel?.deleteCategory(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(
            title: "Отменить",
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        let bgColorView = UIView()
        bgColorView.backgroundColor = .tBackground
        cell.selectedBackgroundView = bgColorView
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        switch indexPath.row {
        case 0: cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case categoriesAmount - 1: cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default: cell.layer.maskedCorners = []
        }
        
        cell.textLabel?.text = viewModel?.getCategoryName(for: indexPath)
        
        let selectedCategoryImageView = UIImageView(image: UIImage(named: "selectTick"))
        let isSelected = indexPath == viewModel?.selectedIndexPath
        cell.accessoryView = isSelected ? selectedCategoryImageView : nil
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel else { return }
        let selectedName = viewModel.getCategoryName(for: indexPath)
        viewModel.selectCategory(name: selectedName)
        delegate?.didSelectCategory(name: selectedName)
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
                    self?.showDeleteConfirmation(for: indexPath)
                }
            ])
        })
    }
}

// MARK: - CategoryEditViewControllerDelegate

extension CategoryViewController: CategoryEditorViewControllerDelegate {
    func didEditedNameForCategory(at index: IndexPath, newName: String) {
        viewModel?.editCategory(at: index, newName: newName)
        navigationController?.popViewController(animated: true)
    }
    
    func didSetNameForNewCategory(name: String) {
        viewModel?.addCategory(name: name)
        navigationController?.popViewController(animated: true)
    }
}


