import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
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
        datePicker.calendar.firstWeekday = 2
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
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
        searchField.delegate = self
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
    
    private lazy var placeholder: PlaceholderView = {
        let placeholder = PlaceholderView(title: "Что будем отслеживать?")
        placeholder.isHidden = true
        placeholder.isUserInteractionEnabled = false
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        return placeholder
    }()
    
    private lazy var trackersCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var categories: [TrackerCategory] = []
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    
    private let mockTrackers = MockTrackers.shared
    
    // MARK: - Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        setUpNavigationBar()
        setUpScreen()
    }
    
    // MARK: - Methods
    
    private func setUpScreen() {
        view.backgroundColor = .tWhite
        
        [trackersCollection, placeholder].forEach { view.addSubview($0) }
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
            trackersCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            placeholder.centerXAnchor.constraint(equalTo: trackersCollection.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: trackersCollection.centerYAnchor),
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
    
    private func reloadData() {
        categories = mockTrackers.categories
        dateChanged()
    }
    
    @objc private func addTrackerButtonPressed() {
        let creatingTrackerVC = CreatingTrackerViewController()
        creatingTrackerVC.delegate = self
        let navigationController = UINavigationController(rootViewController: creatingTrackerVC)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    @objc private func dateChanged() {
        reloadVisibleCategories()
    }
    
    private func reloadVisibleCategories() {
        let filteredText = (searchField.text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filteredText.isEmpty || tracker.name.lowercased().contains(filteredText)
                
                if tracker.schedule == nil {
                    let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
                    return textCondition && !isCompletedToday
                }
                
                let calendar = Calendar.current
                let pickerWeekday = calendar.component(.weekday, from: datePicker.date)
                let filteredWeekday = pickerWeekday == 1 ? 7 : pickerWeekday - 1
                let dateCondition = tracker.schedule?.contains { weekDay in
                    weekDay.rawValue == filteredWeekday
                } ?? false
                
                return textCondition && dateCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                name: category.name,
                trackers: trackers
            )
        }
        
        trackersCollection.reloadData()
        reloadPlaceholder()
    }
    
    private func reloadPlaceholder() {
        placeholder.isHidden = !visibleCategories.isEmpty
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: cellIdentifier,
                for: indexPath
            ) as? TrackersCollectionViewCell
        else { return UICollectionViewCell() }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self
        cell.configureCell(with: tracker)
        
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
        else { return UICollectionReusableView() }
        
        header.titleLabel.text = visibleCategories[indexPath.section].name
        
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

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func checkDate() -> Bool {
        datePicker.date > Date() ? false : true
    }
    
    func toggleTrackerRecord(for id: UUID) {
        let calendar = Calendar.current
        let date = calendar.startOfDay(for: datePicker.date)
        let record = TrackerRecord(id: id, date: date)
        
        if completedTrackers.contains(record) {
            completedTrackers.remove(record)
        } else {
            completedTrackers.insert(record)
        }
    }
    
    func countTrackerRecords(for id: UUID) -> Int {
        completedTrackers.filter { $0.id == id }.count
    }
    
    func isTrackerCompletedToday(id: UUID) -> Bool {
        let today = Calendar.current.startOfDay(for: datePicker.date)
        return completedTrackers.contains { record in
            record.id == id && Calendar.current.isDate(record.date, inSameDayAs: today)
        }
    }
}

extension TrackersViewController: TrackerCreatingDelegate {
    func didCreateNewTracker(in category: TrackerCategory) {
        if let index = categories.firstIndex(where: { $0.name == category.name }) {
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(category.trackers[0])
            categories[index] = TrackerCategory(
                name: category.name,
                trackers: updatedTrackers
            )
        } else {
            categories.append(
                TrackerCategory(
                    name: category.name,
                    trackers: category.trackers
                )
            )
        }
        
        reloadVisibleCategories()
    }
}

extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadVisibleCategories()
        return true
    }
}
