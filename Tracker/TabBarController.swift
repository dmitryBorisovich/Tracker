import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersListViewController = TrackersListViewController()
        trackersListViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tabTrackers"),
            selectedImage: nil
        )
        let trackersNavigationController = UINavigationController(rootViewController: trackersListViewController)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tabStatistics"),
            selectedImage: nil
        )
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)

        self.viewControllers = [trackersNavigationController, statisticsNavigationController]

        tabBar.isTranslucent = false
        tabBar.barTintColor = .tWhite
        tabBar.backgroundColor = .tWhite
        tabBar.tintColor = .tBlue
        tabBar.unselectedItemTintColor = .tGray
    }
}
