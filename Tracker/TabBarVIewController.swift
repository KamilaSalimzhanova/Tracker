import UIKit


final class TabBarViewController: UITabBarController {
    
    let trackersViewController = TrackersViewController()
    let statisticViewController = StatisticViewController()
    
    private enum TabBarItem: String {
        case trackers = "Трекеры"
        case statistics = "Статистика"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundColor = .white
        //trackersViewController.currentDate = Date()
        self.setupViewControllers()
        //self.setupNavigationBar()
    }
    
    private func setupViewControllers() {
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: TabBarItem.trackers.rawValue,
            image: UIImage(named: "Tracker") ?? UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        statisticViewController.tabBarItem = UITabBarItem(
            title: TabBarItem.statistics.rawValue,
            image: UIImage(named: "Statistics") ?? UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersNavigationController, statisticViewController]
    }
}
