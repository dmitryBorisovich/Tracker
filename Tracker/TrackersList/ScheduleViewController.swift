import UIKit

final class ScheduleViewController: UIViewController {
    
    private let dayCellIdentifier = "dayOfWeek"
    
    var selectedDays: [DaysOfWeek]?
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
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
    
    private lazy var scheduleTableView: UITableView = {
//        let tableView = UITableView()
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
    
    private func setUpScreen() {
        setUpNavigationBar()
        view.backgroundColor = .tWhite
        
        [scheduleTableView, completeButton].forEach { view.addSubview($0) }
        
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        scheduleTableView.register(UITableViewCell.self, forCellReuseIdentifier: dayCellIdentifier)
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            completeButton.heightAnchor.constraint(equalToConstant: 60),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
//            scheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            scheduleTableView.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -16)
        ])
    }
    
    private func setUpNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.title = "Расписание"
        navigationController?.navigationBar.tintColor = .tBlack
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
    
    @objc private func completeButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DaysOfWeek.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: dayCellIdentifier, for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .tBackground
        
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        switch indexPath.row {
        case 0: cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case DaysOfWeek.allCases.count - 1: cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default: cell.layer.maskedCorners = []
        }
        
        cell.textLabel?.text = DaysOfWeek.allCases[indexPath.row].rawValue
        
        let switcher = UISwitch()
        switcher.onTintColor = .tBlue
        switcher.tag = indexPath.row
        switcher.addTarget(self, action: #selector(switcherValueChanged), for: .valueChanged)
        cell.accessoryView = switcher
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        switch indexPath.row {
//        case DaysOfWeek.allCases.count - 1:
//            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
//        default:
//            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        }
    }
    
    @objc private func switcherValueChanged(_ sender: UISwitch) {
//        sender.isOn ? selectedDays?.append(DaysOfWeek.allCases[sender.tag])
    }
}

extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
