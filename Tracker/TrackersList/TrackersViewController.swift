import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
    private let letters = [
                "а", "б", "в", "г", "д", "е", "ё", "ж", "з", "и", "й", "к",
                "л", "м", "н", "о", "п", "р", "с", "т", "у", "ф", "х", "ц",
                "ч", "ш" , "щ", "ъ", "ы", "ь", "э", "ю", "я"
            ]
    
    private let cellIdentifier = "cell"
    
    private lazy var addTrackerButton: UIButton = {
        let addTrackerButton = UIButton.systemButton(
            with: UIImage(named: "plusImage") ?? UIImage(),
            target: nil,
            action: #selector(addTrackerButtonPressed)
        )
        addTrackerButton.tintColor = .black
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        return addTrackerButton
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var navigationTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return titleLabel
    }()
    
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
    
    private lazy var trackersCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
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
        
        view.addSubview(trackersCollection)
        trackersCollection.dataSource = self
        trackersCollection.delegate = self
        trackersCollection.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        trackersCollection.backgroundColor = .tWhite
        
        NSLayoutConstraint.activate([
            trackersCollection.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 34),
            trackersCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackersCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpNavigationBar() {
        
        [addTrackerButton, datePicker, headerStackView].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            addTrackerButton.heightAnchor.constraint(equalToConstant: 44),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 44),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            
            datePicker.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            headerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            headerStackView.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor)
        ])
    }
    
    @objc private func addTrackerButtonPressed() {
        
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackersCollectionViewCell
        else { return UICollectionViewCell() }
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize { // Размер ячейки
        CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { // Вертикальные отступы между ячейками
        10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { // Горизонтальные отступы между ячейками
        10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets { // Отступы от краев коллекции
        UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    
}
