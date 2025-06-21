import UIKit

protocol TrackerParamsCollectionViewCellDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String)
    func didSelectColor(_ color: UIColor)
    func didDeselectEmoji()
    func didDeselectColor()
}

enum CollectionCellType {
    case emoji
    case color
}

final class TrackerParamsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI
    
    private lazy var colorView: UIView = {
        let colorView = UIView()
        colorView.layer.cornerRadius = 8
        colorView.translatesAutoresizingMaskIntoConstraints = false
        return colorView
    }()
    
    private lazy var colorBackgroundView: UIView = {
        let colorView = UIView()
        colorView.layer.cornerRadius = 8
        colorView.layer.backgroundColor = .none
        colorView.layer.borderWidth = 3
        colorView.layer.borderColor = UIColor.clear.cgColor
        colorView.translatesAutoresizingMaskIntoConstraints = false
        return colorView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
    }()
    
    private lazy var emojiView: UIView = {
        let emojiView = UIView()
        emojiView.backgroundColor = .clear
        emojiView.layer.cornerRadius = 16
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        return emojiView
    }()
    
    // MARK: - Properties
    
    private let emojiArray = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    private let colorsArray = [
        UIColor(named: "trackerRed"), UIColor(named: "trackerOrange"),
        UIColor(named: "trackerDarkBlue"), UIColor(named: "trackerDeepPurple"),
        UIColor(named: "trackerGreen"), UIColor(named: "trackerPink"),
        UIColor(named: "trackerLightPink"), UIColor(named: "trackerBlue"),
        UIColor(named: "trackerLightGreen"), UIColor(named: "trackerNavy"),
        UIColor(named: "trackerCarrot"), UIColor(named: "trackerLilac"),
        UIColor(named: "trackerSand"), UIColor(named: "trackerSapphire"),
        UIColor(named: "trackerViolet"), UIColor(named: "trackerPurple"),
        UIColor(named: "trackerIris"), UIColor(named: "trackerDarkGreen")
    ]
    
    private var cellType: CollectionCellType?
    
    weak var delegate: TrackerParamsCollectionViewCellDelegate?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setUpCellWithEmoji() {
        contentView.addSubview(emojiView)
        emojiView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiView.heightAnchor.constraint(equalToConstant: 52),
            emojiView.widthAnchor.constraint(equalToConstant: 52),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor)
        ])
    }
    
    private func setUpCellWithColor() {
        contentView.addSubview(colorBackgroundView)
        colorBackgroundView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorBackgroundView.heightAnchor.constraint(equalToConstant: 52),
            colorBackgroundView.widthAnchor.constraint(equalToConstant: 52),
            
            colorView.centerXAnchor.constraint(equalTo: colorBackgroundView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: colorBackgroundView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func configureCellWithEmoji(for indexPath: IndexPath) {
        cellType = .emoji
        setUpCellWithEmoji()
        emojiLabel.text = emojiArray[indexPath.item]
    }
    
    private func configureCellWithColor(for indexPath: IndexPath) {
        cellType = .color
        setUpCellWithColor()
        colorView.backgroundColor = colorsArray[indexPath.item]
    }
    
    func configureCell(with type: CollectionCellType, for indexPath: IndexPath) {
        switch type {
        case .emoji:
            configureCellWithEmoji(for: indexPath)
        case .color:
            configureCellWithColor(for: indexPath)
        }
    }
    
    func didSelectCell() {
        switch cellType {
        case .emoji:
            emojiView.backgroundColor = .tLightGray
            delegate?.didSelectEmoji(emojiLabel.text ?? "🌚")
        case .color:
            let borderColor = colorView.backgroundColor?.withAlphaComponent(0.3) ?? .tGrayAlpha30
            colorBackgroundView.layer.borderColor = borderColor.cgColor
            delegate?.didSelectColor(colorView.backgroundColor ?? .tGreen)
        case nil:
            break
        }
    }
    
    func didDeselectCell() {
        switch cellType {
        case .emoji:
            emojiView.backgroundColor = .clear
            delegate?.didDeselectEmoji()
        case .color:
            colorBackgroundView.layer.borderColor = UIColor.clear.cgColor
            delegate?.didDeselectColor()
        case nil:
            break
        }
    }
}
