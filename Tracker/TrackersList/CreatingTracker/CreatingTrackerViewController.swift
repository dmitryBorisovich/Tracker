import UIKit

final class CreatingTrackerViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.tag = ButtonTag.habit.rawValue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.tWhite, for: .normal)
        button.backgroundColor = .tBlack
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(someButtonPressed),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.tag = ButtonTag.irregularEvent.rawValue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.tWhite, for: .normal)
        button.backgroundColor = .tBlack
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(someButtonPressed),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            habitButton,
            irregularEventButton
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private enum ButtonTag: Int {
        case habit = 0
        case irregularEvent = 1
    }
    
    // MARK: - Properties
    
    weak var delegate: TrackerCreatingDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
    
    // MARK: - Methods
    
    private func setUpScreen() {
        navigationItem.title = "Создание трекера"
        navigationController?.navigationBar.tintColor = .tBlack
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        
        view.backgroundColor = .tWhite
        
        view.addSubview(buttonsStackView)
        NSLayoutConstraint.activate([
            buttonsStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func someButtonPressed(_ sender: UIButton) {
        let isScheduleNeeded = sender.tag == ButtonTag.habit.rawValue
        let trackerVC = TrackerSetupViewController(isScheduleNeeded: isScheduleNeeded)
        trackerVC.delegate = delegate
        navigationController?.pushViewController(trackerVC, animated: true)
    }
//    @objc private func habitButtonPressed() {
//        let newHabitViewController = NewHabitViewController()
//        newHabitViewController.delegate = delegate
//        navigationController?.pushViewController(newHabitViewController, animated: true)
//    }
//    
//    @objc private func irregularEventButtonPressed() {
//        let newEventViewController = NewEventViewController()
//        newEventViewController.delegate = delegate
//        navigationController?.pushViewController(newEventViewController, animated: true)
//    }
}
