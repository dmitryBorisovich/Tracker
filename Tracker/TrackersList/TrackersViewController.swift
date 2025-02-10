import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
    private let letters = [
                "а", "б", "в", "г", "д", "е", "ё", "ж", "з", "и", "й", "к",
                "л", "м", "н", "о", "п", "р", "с", "т", "у", "ф", "х", "ц",
                "ч", "ш" , "щ", "ъ", "ы", "ь", "э", "ю", "я"
            ]
    
    private let cellIdentifier = "cell"
    private let sectionHeaderIdentifier = "sectionHeader"
    
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
        trackersCollection.register(
            TrackersSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: sectionHeaderIdentifier
        )
        trackersCollection.backgroundColor = .tWhite
        trackersCollection.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        
        NSLayoutConstraint.activate([
            trackersCollection.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 8),
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
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: sectionHeaderIdentifier,
                for: indexPath
            ) as? TrackersSupplementaryView
        else
            { return UICollectionReusableView() }
        
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize { // Размер ячейки
        let cellWidth = (collectionView.frame.width - 16 * 2 - 9) / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { // Вертикальные отступы между ячейками
        0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { // Горизонтальные отступы между ячейками
        9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets { // Отступы от краев коллекции
        UIEdgeInsets(top: 16, left: 16, bottom: 12, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 18)
    }
    
}
