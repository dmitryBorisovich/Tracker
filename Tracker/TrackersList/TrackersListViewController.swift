import UIKit

final class TrackersListViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var addTrackerButton: UIBarButtonItem = {
        let addTrackerButton = UIBarButtonItem(
            image: UIImage(named: "addTrackerButton"),
            style: .plain,
            target: nil,
            action: #selector(addTrackerButtonPressed)
        )
        addTrackerButton.tintColor = .black
        return addTrackerButton
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        return datePicker
    }()
    
    private lazy var navigationTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return titleLabel
    }()
    
//    private lazy var searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        searchBar.searchBarStyle = .minimal
//        searchBar.placeholder = "Поиск"
//        searchBar.searchTextField.layer.cornerRadius = 10
//        searchBar.searchTextField.layer.masksToBounds = true
//        searchBar.searchTextField.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            searchBar.searchTextField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor)
//        ])
//        return searchBar
//    }()
    
    private lazy var searchField: UISearchTextField = {
        let searchField = UISearchTextField()
        searchField.placeholder = "Поиск"
        searchField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return searchField
    }()

    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            navigationTitleLabel,
            searchField
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 7
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var categories: [TrackerCategory]?
    var completedTrackers: [TrackerRecord]?
    
    // MARK: - Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpScreen()
    }
    
    // MARK: - Methods
    
    private func setUpScreen() {
        view.backgroundColor = .tWhite
    }
    
    private func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = addTrackerButton
        
        let navigationBarDatePicker = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = navigationBarDatePicker
        
        view.addSubview(headerStackView)
        NSLayoutConstraint.activate([
            headerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    @objc private func addTrackerButtonPressed() {
        
    }
}
