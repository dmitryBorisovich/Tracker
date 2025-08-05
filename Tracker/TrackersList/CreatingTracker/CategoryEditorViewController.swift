import UIKit

protocol CategoryEditorViewControllerDelegate: AnyObject {
    func didEditedNameForCategory(at index: IndexPath, newName: String)
    func didSetNameForNewCategory(name: String)
}

final class CategoryEditorViewController: UIViewController {
    
    enum CategoryOperation {
        case editing
        case creating
    }
    
    // MARK: - UI
    
    private enum Strings {
        static let navNewCategoryTitle = "Новая категория"
        static let placeholderTitle = "Введите название категории"
        static let navEditCategoryTitle = "Редактирование категории"
        static let completeButtonTitle = "Готово"
    }
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.completeButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.tWhite, for: .normal)
        button.backgroundColor = .tBlack
        button.layer.cornerRadius = 16
        button.addTarget(self,
                         action: #selector(completeButtonPressed),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.text = action == .creating ? nil : oldName
        textField.placeholder = Strings.placeholderTitle
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = .tBackground
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var textStatusLabel: UILabel = {
        let status = UILabel()
        status.textColor = .tRed
        status.font = .systemFont(ofSize: 17)
        status.text = ""
        status.textAlignment = .center
        return status
    }()
    
    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [categoryNameTextField, textStatusLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    

    
    // MARK: - Properties
    
    private let action: CategoryOperation
    private let index: IndexPath?
    private let oldName: String?
    private var newCategoryName: String?
    
    weak var delegate: CategoryEditorViewControllerDelegate?
    
    // MARK: - Init
    
    init(_ action: CategoryOperation, index: IndexPath? = nil, currentName: String? = nil) {
        self.action = action
        self.index = index
        self.oldName = currentName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
    
    // MARK: - Methods
    
    private func setUpScreen() {
        setUpNavigationBar()
        view.backgroundColor = .tWhite
        
        [textFieldStackView,
         completeButton].forEach { view.addSubview($0) }
        categoryNameTextField.delegate = self
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            textFieldStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            completeButton.heightAnchor.constraint(equalToConstant: 60),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setUpNavigationBar() {
        navigationItem.hidesBackButton = true
        switch action {
        case .editing:
            navigationItem.title = Strings.navEditCategoryTitle
        case .creating:
            navigationItem.title = Strings.navNewCategoryTitle
        }
        navigationController?.navigationBar.tintColor = .tBlack
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
    
    private func updateCreateButtonState() {
        let isReady = newCategoryName?.count ?? 0 > 0
        completeButton.isEnabled = isReady
        completeButton.backgroundColor = isReady ? .tBlack : .tGray
    }
    
    @objc private func completeButtonPressed() {
        guard let newCategoryName else { return }
        if action == .creating {
            delegate?.didSetNameForNewCategory(name: newCategoryName)
        } else {
            guard let index else { return }
            delegate?.didEditedNameForCategory(at: index, newName: newCategoryName)
        }
    }
}

// MARK: - UITextFieldDelegate

extension CategoryEditorViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > 38 {
            textStatusLabel.text = "Ограничение 38 символов"
            textFieldStackView.spacing = 8
            return false
        }
        
        textStatusLabel.text = nil
        textFieldStackView.spacing = 0
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newCategoryName = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        newCategoryName = textField.text
        updateCreateButtonState()
    }
}

