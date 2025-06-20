import UIKit

final class NewEventViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var eventNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название события"
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
        let stackView = UIStackView(arrangedSubviews: [eventNameTextField, textStatusLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var eventParamsTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.tRed, for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(named: "tRed")?.cgColor
        cancelButton.addTarget(self,
                               action: #selector(cancelButtonPressed),
                               for: .touchUpInside)
        return cancelButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton()
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.titleLabel?.textColor = .tWhite
        createButton.backgroundColor = .tGray
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self,
                               action: #selector(createButtonPressed),
                               for: .touchUpInside)
        return createButton
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    
    private let eventParamsCellIdentifier = "eventParamsCell"
    private let cellName = "Категория"
    private var selectedCategory: String?
    private var trackerName: String?
    
    weak var delegate: TrackerCreatingDelegate?
    
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
         eventParamsTableView,
         buttonsStackView].forEach { view.addSubview($0) }
        
        eventNameTextField.delegate = self
        
        eventParamsTableView.dataSource = self
        eventParamsTableView.delegate = self
        eventParamsTableView.register(UITableViewCell.self, forCellReuseIdentifier: eventParamsCellIdentifier)
        eventParamsTableView.layer.cornerRadius = 16
        
        setUpConstraints()
    }
    
    private func setUpNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.title = "Новое нерегулярное событие"
        navigationController?.navigationBar.tintColor = .tBlack
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            textFieldStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            eventNameTextField.heightAnchor.constraint(equalToConstant: 75),
            textStatusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            eventParamsTableView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 24),
            eventParamsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            eventParamsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            eventParamsTableView.heightAnchor.constraint(equalToConstant: 75),
            
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func cancelButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func createButtonPressed() {
        guard let trackerName, !trackerName.isEmpty,
              let selectedCategory
        else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: .tGreen,
            emoji: "🍏",
            schedule: nil
        )
        
        let category = TrackerCategory(name: selectedCategory, trackers: [tracker])
        delegate?.didCreateNewTracker(in: category)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NewEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: eventParamsCellIdentifier)
        cell.selectionStyle = .none
        cell.backgroundColor = .tBackground
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.text = cellName
        
        cell.detailTextLabel?.textColor = .tGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.text = selectedCategory
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCategoryViewController()
    }
}

// MARK: - UITextFieldDelegate

extension NewEventViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > 38 {
            textStatusLabel.text = "Ограничение 38 символов"
            textStatusLabel.isHidden = false
            return false
        }
        
        textStatusLabel.text = nil
        textStatusLabel.isHidden = true
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerName = textField.text
        textField.resignFirstResponder()
        updateCreateButtonState()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        trackerName = textField.text
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let isEnabled = (trackerName?.isEmpty == false) && (selectedCategory != nil)
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .tBlack : .tGray
    }
}

// MARK: - CategoryViewControllerDelegate

extension NewEventViewController: CategoryViewControllerDelegate {
    func didSelectCategory(name: String) {
        selectedCategory = name
        eventParamsTableView.reloadData()
        updateCreateButtonState()
    }
    
    private func showCategoryViewController() {
        let categoryVC = CategoryViewController(selectedCategoryName: selectedCategory)
        categoryVC.delegate = self
        navigationController?.pushViewController(categoryVC, animated: true)
    }
}
