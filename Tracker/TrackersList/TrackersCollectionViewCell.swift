import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    private lazy var colorView: UIView = {
        let colorView = UIView()
        colorView.backgroundColor = .tGreen
        colorView.layer.cornerRadius = 16
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor(named: "tGrayAlpha30")?.cgColor
        colorView.translatesAutoresizingMaskIntoConstraints = false
        return colorView
    }()
    
    private lazy var trackerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = "Пройти урок по Swift"
        label.textColor = .tWhite
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
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.font = UIFont.systemFont(ofSize: 14)
        emojiLabel.text = "😪"
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
    
    private lazy var addDayButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "plusButton") ?? UIImage(),
            target: nil,
            action: #selector(addDayButtonPressed)
        )
        button.tintColor = .tGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    @objc private func addDayButtonPressed() {}
}
