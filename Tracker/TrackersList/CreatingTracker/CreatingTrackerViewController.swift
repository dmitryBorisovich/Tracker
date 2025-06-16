import UIKit

final class CreatingTrackerViewController: UIViewController {
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.tWhite, for: .normal)
        button.backgroundColor = .tBlack
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(habitButtonPressed),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.tWhite, for: .normal)
        button.backgroundColor = .tBlack
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(irregularEventButtonPressed),
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
    
    weak var delegate: TrackerCreatingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
    
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
    
    @objc private func habitButtonPressed() {
        let newHabitViewController = NewHabitViewController()
        newHabitViewController.delegate = delegate
        navigationController?.pushViewController(newHabitViewController, animated: true)
    }
    
    @objc private func irregularEventButtonPressed() {
        let newEventViewController = NewEventViewController()
        newEventViewController.delegate = delegate
        navigationController?.pushViewController(newEventViewController, animated: true)
    }
}
