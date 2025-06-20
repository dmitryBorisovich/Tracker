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
            title: "Трекеры",
            image: UIImage(named: "tabTrackers"),
            selectedImage: nil
        )
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
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
