import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - UI
    
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
    
    // MARK: - Properties
    
    private let cellIdentifier = "cell"
    private let sectionHeaderIdentifier = "sectionHeader"
    
    private var currentDate: Date {
        Calendar.current.startOfDay(for: datePicker.date)
    }
    
    private var trackerStore = TrackerStore()
    private var trackerRecordsStore = TrackerRecordStore()
    private var trackerCategoriesStore = TrackerCategoryStore()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerStore.delegate = self
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
        
        reloadPlaceholder()
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
        let searchText = searchField.text?.lowercased() ?? ""
        trackerStore.updatePredicate(filterText: searchText, date: currentDate)
        reloadPlaceholder()
    }
    
    private func reloadPlaceholder() {
        let isCollectionEmpty = trackersCollection.numberOfSections == 0
        placeholder.isHidden = !isCollectionEmpty
    }
    
    private func deleteTracker(index: IndexPath) {
        do {
            try trackerStore.deleteTracker(at: index)
        } catch {
            print("ошибка")
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore.numberOfItemsInSection(section)
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
        
        guard let tracker = trackerStore.tracker(at: indexPath) else { return UICollectionViewCell() }
        
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
        
        let sectionName = trackerStore.sectionName(indexPath.section)
        header.titleLabel.text = sectionName
        
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

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

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Удалить") { [weak self] _ in
                    self?.deleteTracker(index: indexPath)
                }
            ])
        })
    }
}
// MARK: - UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadVisibleCategories()
        return true
    }
}

// MARK: - TrackersCollectionViewCellDelegate

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func checkDate() -> Bool {
        currentDate <= Date()
    }
    
    func toggleTrackerRecord(for id: UUID) {
        let record = TrackerRecord(id: id, date: currentDate)
        do {
            try trackerRecordsStore.toggleTrackerRecord(record: record)
        } catch {
            print("ошибка \(error.localizedDescription)")
        }
    }
    
    func countTrackerRecords(for id: UUID) -> Int {
        do {
            return try trackerRecordsStore.countTrackerRecords(for: id)
        } catch {
            print("ошибка")
            return 0
        }
    }
    
    func isTrackerCompletedToday(id: UUID) -> Bool {
        let record = TrackerRecord(id: id, date: currentDate)
        do {
            return try trackerRecordsStore.isTrackerCompletedToday(record: record)
        } catch {
            print("ошибка")
            return false
        }
    }
}

// MARK: - TrackerCreatingDelegate

extension TrackersViewController: TrackerCreatingDelegate {
    func didCreateNewTracker(in category: TrackerCategory) {
        guard let tracker = category.trackers.first else { return }
        do {
            try trackerStore.addTracker(tracker, to: category)
        } catch {
            print("ошибка")
        }
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    
    func didUpdate(_ update: TrackerStoreUpdate) {
        trackersCollection.reloadData()
        //TODO: - Доделать performBatchUpdates
    }
}
