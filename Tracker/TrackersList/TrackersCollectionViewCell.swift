import UIKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func checkDate() -> Bool
    func toggleTrackerRecord(for id: UUID)
    func countTrackerRecords(for id: UUID) -> Int
    func isTrackerCompletedToday(id: UUID) -> Bool
}

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI
    
    private lazy var trackerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var colorView: UIView = {
        let colorView = UIView()
        colorView.layer.cornerRadius = 16
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor(named: "tGrayAlpha30")?.cgColor
        colorView.translatesAutoresizingMaskIntoConstraints = false
        return colorView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.font = UIFont.systemFont(ofSize: 14)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
    }()
    
    private lazy var daysCounterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiView: UIView = {
        let emojiView = UIView()
        emojiView.backgroundColor = .tWhiteAlpha30
        emojiView.layer.cornerRadius = 12
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        return emojiView
    }()
    
    private lazy var addDayButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.setImage(UIImage(named: "plusButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(UIImage(named: "completedButton")?.withRenderingMode(.alwaysOriginal), for: .selected)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(addDayButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private var trackerId: UUID?
    
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setUpCell() {
        contentView.addSubview(colorView)
        [daysCounterLabel, addDayButton].forEach { contentView.addSubview($0) }
        [trackerNameLabel, emojiView].forEach { colorView.addSubview($0) }
        emojiView.addSubview(emojiLabel)
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            emojiView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            
            trackerNameLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            trackerNameLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            
            addDayButton.heightAnchor.constraint(equalToConstant: 34),
            addDayButton.widthAnchor.constraint(equalToConstant: 34),
            addDayButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            addDayButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            daysCounterLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16),
            daysCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCounterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -54)
        ])
    }
    
    @objc private func addDayButtonPressed(_ sender: UIButton) {
        guard
            let delegate,
            let trackerId,
            delegate.checkDate()
        else {
            return
        }
        
        delegate.toggleTrackerRecord(for: trackerId)
        
        updateButtonState()
        
        let numberOfDays = delegate.countTrackerRecords(for: trackerId)
        changeDaysCounter(for: numberOfDays)
    }
    
    private func updateButtonState() {
        guard let trackerId else { return }
        
        let isCompletedToday = delegate?.isTrackerCompletedToday(id: trackerId) ?? false
        addDayButton.isSelected = isCompletedToday
        addDayButton.backgroundColor = isCompletedToday ? addDayButton.tintColor : .clear
    }
    
    func configureCell(with tracker: Tracker) {
        self.trackerId = tracker.id
        
        trackerNameLabel.text = tracker.name
        colorView.backgroundColor = tracker.color
        addDayButton.tintColor = tracker.color
        emojiLabel.text = tracker.emoji
        
        updateButtonState()
        
        let numberOfDays = delegate?.countTrackerRecords(for: tracker.id) ?? 0
        changeDaysCounter(for: numberOfDays)
    }
    
    func changeDaysCounter(for number: Int) {
        var counterText: String
        
        let lastDigit = number % 10
        let lastTwoDigits = number % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            counterText = "\(number) дней"
        }
        
        switch lastDigit {
        case 1:
            counterText = "\(number) день"
        case 2...4:
            counterText = "\(number) дня"
        default:
            counterText = "\(number) дней"
        }
        
        daysCounterLabel.text = counterText
    }
}
