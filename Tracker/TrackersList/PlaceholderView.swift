import UIKit

final class PlaceholderView: UIView {
    
    // MARK: - Private properties
    
    private let stackView: UIStackView
    private let imageView: UIImageView
    private let titleLabel: UILabel
    
    // MARK: - Init
    
    init(title: String) {
        imageView = UIImageView(image: UIImage(named: "starPlaceholder"))
        titleLabel = UILabel()
        
        stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        
        super.init(frame: .zero)
        
        setupView(title: title)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupView(title: String) {
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }
}
