import UIKit

final class NewHabitViewController: UIViewController {
    
    private let habitParamsCellIdentifier = "habitParamsCell"
    private let cellNames = [
        "Категория",
        "Расписание"
    ]
    
    private lazy var habitNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название привычки"
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
        let stackView = UIStackView(arrangedSubviews: [habitNameTextField, textStatusLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var habitParamsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
    
    private func setUpScreen() {
        setUpNavigationBar()
        view.backgroundColor = .tWhite
        
        [textFieldStackView,
         habitParamsTableView,
         buttonsStackView].forEach { view.addSubview($0) }
        
        habitParamsTableView.dataSource = self
        habitParamsTableView.delegate = self
        habitParamsTableView.register(UITableViewCell.self, forCellReuseIdentifier: habitParamsCellIdentifier)
        
        setUpConstraints()
    }
    
    private func setUpNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.title = "Новая привычка"
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
            textFieldStackView.heightAnchor.constraint(equalToConstant: 113),
            habitNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            habitParamsTableView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 24),
            habitParamsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            habitParamsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitParamsTableView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16),
            
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func cancelButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
}

extension NewHabitViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: habitParamsCellIdentifier)
        cell.selectionStyle = .none
        cell.backgroundColor = .tBackground
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        switch indexPath.row {
        case 0: cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        default: cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.accessoryType = .disclosureIndicator
        
        cell.textLabel?.text = cellNames[indexPath.row]
        cell.detailTextLabel?.text = nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        default: cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
    }
    
    
}

extension NewHabitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: print("D")
        default:
            let scheduleViewController = ScheduleViewController()
            navigationController?.pushViewController(scheduleViewController, animated: true)
        }
    }
}
