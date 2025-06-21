import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - UI
    
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
        stackView.spacing = 0
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
    
    private lazy var trackerParamsCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.isScrollEnabled = false
        collection.allowsMultipleSelection = true
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // MARK: - Properties
    
    private let habitParamsCellIdentifier = "habitParamsCell"
    private let cellNames = [
        "Категория",
        "Расписание"
    ]
    
    private let trackerParamsCellIdentifier = "trackerParamsCell"
    private let sectionHeaderIdentifier = "sectionHeader"
    
    private var selectedDays: [DaysOfWeek] = []
    private var selectedCategory: String?
    private var scheduleLabel: String?
    private var trackerName: String?
    
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    
    weak var delegate: TrackerCreatingDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Форсируем расчёт layout
        trackerParamsCollection.layoutIfNeeded()
        
        // Устанавливаем высоту = contentSize
        let height = trackerParamsCollection.contentSize.height
        trackerParamsCollection.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        // Обновляем скроллвью
        containerView.layoutIfNeeded()
        scrollView.contentSize = containerView.bounds.size
    }
    
    // MARK: - Methods
    
    private func setUpScreen() {
        setUpNavigationBar()
        view.backgroundColor = .tWhite
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        [textFieldStackView,
         habitParamsTableView,
         trackerParamsCollection,
         buttonsStackView].forEach { containerView.addSubview($0) }
        
        habitNameTextField.delegate = self
        
        habitParamsTableView.dataSource = self
        habitParamsTableView.delegate = self
        habitParamsTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: habitParamsCellIdentifier
        )
        
        trackerParamsCollection.dataSource = self
        trackerParamsCollection.delegate = self
        trackerParamsCollection.register(
            TrackerParamsCollectionViewCell.self,
            forCellWithReuseIdentifier: trackerParamsCellIdentifier
        )
        trackerParamsCollection.register(
            TrackersSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: sectionHeaderIdentifier
        )
        
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
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textFieldStackView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 24),
            textFieldStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            habitNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            habitParamsTableView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 24),
            habitParamsTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            habitParamsTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            habitParamsTableView.heightAnchor.constraint(equalToConstant: 150), // TODO: ОПТИМИЗИРОВАТЬ ДЛЯ ДИНАМИЧЕСКОГО РАСЧЕТА
            
            trackerParamsCollection.topAnchor.constraint(equalTo: habitParamsTableView.bottomAnchor, constant: 32),
            trackerParamsCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerParamsCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.topAnchor.constraint(equalTo: trackerParamsCollection.bottomAnchor, constant: 16),
            buttonsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func cancelButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func createButtonPressed() {
        guard let trackerName,
              trackerName.count > 0,
              let selectedCategory,
              selectedDays.count > 0
        else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: .tGreen,
            emoji: "🍏",
            schedule: selectedDays
        )
        
        let categoryName = selectedCategory
        let category = TrackerCategory(name: categoryName, trackers: [tracker])
        
        delegate?.didCreateNewTracker(in: category)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

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
        
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.text = cellNames[indexPath.row]
        
        cell.detailTextLabel?.textColor = .tGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.text = nil
        
        switch indexPath.row {
        case 0:
            cell.detailTextLabel?.text = selectedCategory ?? nil
        case 1:
            cell.detailTextLabel?.text = scheduleLabel
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        default: cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
    }
}

// MARK: - UITableViewDelegate

extension NewHabitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showCategoryViewController()
            //TODO: Реализовать создание новой категории (спринт 15)
        default:
            showScheduleViewController()
        }
    }
}

// MARK: - UITextFieldDelegate

extension NewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > 38 {
            textStatusLabel.text = "Ограничение 38 символов"
            textFieldStackView.spacing = 8
            return false
        }
        
        textStatusLabel.text = nil
        textFieldStackView.spacing = 0
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerName = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        trackerName = textField.text
    }
}

// MARK: - UICollectionViewDataSource

extension NewHabitViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        18
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: trackerParamsCellIdentifier,
                for: indexPath
            ) as? TrackerParamsCollectionViewCell
        else { return UICollectionViewCell() }
        
        let cellType: CollectionCellType = indexPath.section == 0 ? .emoji : .color
        cell.configureCell(with: cellType, for: indexPath)
        
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
        
        header.titleLabel.text = indexPath.section == 0 ? "Emoji" : "Цвет"
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerParamsCollectionViewCell
        
        if indexPath.section == 0 {
            if let lastIndex = selectedEmojiIndex, lastIndex != indexPath {
                collectionView.deselectItem(at: lastIndex, animated: true)
                let lastSelectedCell = collectionView.cellForItem(
                    at: lastIndex
                ) as? TrackerParamsCollectionViewCell
                lastSelectedCell?.didDeselectCell()
            }
            selectedEmojiIndex = indexPath
            cell?.didSelectCell()
        } else {
            if let lastIndex = selectedColorIndex, lastIndex != indexPath {
                collectionView.deselectItem(at: lastIndex, animated: true)
                let lastSelectedCell = collectionView.cellForItem(at: lastIndex) as? TrackerParamsCollectionViewCell
                lastSelectedCell?.didDeselectCell()
            }
            selectedColorIndex = indexPath
            cell?.didSelectCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerParamsCollectionViewCell
        cell?.didDeselectCell()
        
        if indexPath.section == 0 {
            selectedEmojiIndex = nil
        } else {
            selectedColorIndex = nil
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    // Размер ячейки
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - 37
        let cellSide = (availableWidth - 5 * 5) / 6
        return CGSize(width: cellSide, height: cellSide)
    }
    
    // Вертикальные отступы между ячейками
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    // Горизонтальные отступы между ячейками
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    // Отступы от краев коллекции
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 18)
    }
}

// MARK: - ScheduleViewControllerDelegate

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func didSelectDays(days: [DaysOfWeek]) {
        selectedDays = days
        updateScheduleDisplay()
    }
    
    private func updateScheduleDisplay() {
        if selectedDays.count == DaysOfWeek.allCases.count {
            scheduleLabel = "Каждый день"
        } else if selectedDays.isEmpty {
            scheduleLabel = nil
        } else {
            scheduleLabel = selectedDays
                .sorted(by: { $0.rawValue < $1.rawValue })
                .map { $0.shortName }
                .joined(separator: ", ")
        }
        
        habitParamsTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }
    
    private func showScheduleViewController() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.delegate = self
        scheduleVC.selectedDays = Set(selectedDays)
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
}

// MARK: - CategoryViewControllerDelegate

extension NewHabitViewController: CategoryViewControllerDelegate {
    func didSelectCategory(name: String) {
        selectedCategory = name
        habitParamsTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    private func showCategoryViewController() {
        let categoryVC = CategoryViewController(selectedCategoryName: selectedCategory)
        categoryVC.delegate = self
        navigationController?.pushViewController(categoryVC, animated: true)
    }
}

// MARK: - TrackerParamsCollectionViewCellDelegate

// TODO: Реализовать методы передачи параметров в трекер
extension NewHabitViewController: TrackerParamsCollectionViewCellDelegate {
    func didSelectEmoji(_ emoji: String) {
        
    }
    
    func didSelectColor(_ color: UIColor) {
        
    }
    
    func didDeselectEmoji() {
        
    }
    
    func didDeselectColor() {
        
    }
}
