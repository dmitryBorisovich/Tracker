import UIKit

final class PageViewController: UIViewController {
    
    enum ImageStrings: String {
        case firstBackgroundName = "obBackground1"
        case secondBackgroundName = "obBackground2"
    }
    
    private let text: String
    private let imageName: ImageStrings
    
    init(imageName: ImageStrings) {
        self.imageName = imageName
        switch imageName {
        case .firstBackgroundName:
            text = "Отслеживайте только то, что хотите"
        case .secondBackgroundName:
            text = "Даже если это не литры воды и йога"
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    private func setupScreen() {
        let imageView = UIImageView(image: UIImage(named: imageName.rawValue))
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 32, weight: .bold)
        textLabel.textColor = .tBlack
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        [imageView, textLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        let calculatedHeight = view.frame.height * 0.4
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -calculatedHeight),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
