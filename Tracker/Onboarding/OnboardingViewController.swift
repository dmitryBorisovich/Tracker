import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private enum Strings {
        static let buttonTitle = "Вот это технологии!"
    }
    
    private lazy var pages: [UIViewController] = [
        PageViewController(imageName: .firstBackgroundName),
        PageViewController(imageName: .secondBackgroundName)
    ]
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.buttonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.tWhite, for: .normal)
        button.backgroundColor = .tBlack
        button.layer.cornerRadius = 16
        button.addTarget(self,
                         action: #selector(startButtonPressed),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .tBlack
        pageControl.pageIndicatorTintColor = .tBlackAlpha30
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let userDefaultsService = UserDefaultsService.shared
    private var isTransitionInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        setupScreen()
    }
    
    private func setupScreen() {
        [startButton, pageControl].forEach { view.addSubview($0) }
        print("Subviews: \(view.subviews)")
        NSLayoutConstraint.activate([
            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -24)
        ])
    }
    
    @objc private func startButtonPressed() {
        userDefaultsService.isOnboardingCompleted = true
        
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = TabBarController()
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard !isTransitionInProgress else { return nil }
        
        guard
            let viewControllerIndex = pages.firstIndex(of: viewController)
        else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            let index = pages.count - 1
            return pages[index]
        }
        return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard !isTransitionInProgress else { return nil }
        
        guard
            let viewControllerIndex = pages.firstIndex(of: viewController)
        else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages[0]
        }
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        isTransitionInProgress = true
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        isTransitionInProgress = false
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

