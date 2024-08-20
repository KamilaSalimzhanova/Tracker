import UIKit


final class TabBarViewController: UITabBarController {
    
    private enum TabBarItem: String {
        case trackers
        case statistics
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.backgroundColor = .ypBackground
        self.setupViewControllers()
        let separator = UIView()
        separator.backgroundColor = UIColor.ypSeparator
        view.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupViewControllers() {
        
        let trackersViewController = TrackersViewController()
        let statisticViewController = StatisticsViewController()
        
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBarItemTrackers", comment: "First text displayed on tab bar stage"),
            image: UIImage(named: "Tracker") ?? UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        statisticViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBarItemStatistics", comment: "Second text displayed on tab bar stage"),
            image: UIImage(named: "Statistics") ?? UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersNavigationController, statisticViewController]
    }
}
