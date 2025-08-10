import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        configureTabBarAppearance()
    }
    
    private func setupViewControllers() {
        let trackersVC = TrackersViewController()
        trackersVC.tabBarItem = UITabBarItem(
            title: Strings.trackersTitle,
            image: UIImage(named: "tabTrackers"),
            selectedImage: nil
        )
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: Strings.statisticTitle,
            image: UIImage(named: "tabStatistics"),
            selectedImage: nil
        )
        let statisticsNC = UINavigationController(rootViewController: statisticsVC)
        
        viewControllers = [trackersVC, statisticsNC]
    }
    
    private func configureTabBarAppearance() {
        tabBar.isTranslucent = false
        tabBar.barTintColor = .tWhite
        tabBar.backgroundColor = .tWhite
        tabBar.tintColor = .tBlue
        tabBar.unselectedItemTintColor = .tGray
    }
}

extension TabBarController {
    private enum Strings {
        static let trackersTitle = NSLocalizedString(
            "tabBar.trackersTitle",
            comment: "name for trackers tabBarItem"
        )
        
        static let statisticTitle = NSLocalizedString(
            "tabBar.statisticTitle",
            comment: "name for statistic tabBarItem"
        )
    }
}
