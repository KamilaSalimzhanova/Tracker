import UIKit


final class TabBarViewController: UITabBarController {
    
    let trackersViewController = TrackersViewController()
    let statisticViewController = StatisticViewController()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
    private enum TabBarItem: String {
        case trackers = "Трекеры"
        case statistics = "Статистика"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundColor = .white
        trackersViewController.currentDate = Date()
        self.setupViewControllers()
        self.setupNavigationBar()
    }
    
    private func setupViewControllers() {
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: TabBarItem.trackers.rawValue,
            image: UIImage(named: "Tracker") ?? UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        statisticViewController.tabBarItem = UITabBarItem(
            title: TabBarItem.statistics.rawValue,
            image: UIImage(named: "Statistics") ?? UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersViewController, statisticViewController]
    }
    
    private func setupNavigationBar() {
        let leftItem = UIImage(named: "Plus") ?? UIImage(systemName: "plus")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: leftItem,
            style: .plain,
            target: self,
            action: #selector(addTarget)
        )
        self.navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: setUpDatePicket())
        self.navigationItem.rightBarButtonItem?.customView?.layer.masksToBounds = true
        self.navigationItem.rightBarButtonItem?.customView?.layer.cornerRadius = 8
    }
    
    private func setUpDatePicket() -> UIDatePicker {
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            datePicker.heightAnchor.constraint(equalToConstant: 34)])
        datePicker.addTarget(self,
                             action: #selector(datePickerValueChanged(_:)),
                             for: .valueChanged)

        return datePicker
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        trackersViewController.currentDate = selectedDate
    }
    
    @objc func addTarget() {
        print("Add target")
        let viewController = TrackerTypeViewController()
        viewController.trackerViewController = trackersViewController
        viewController.modalPresentationStyle = .popover
        self.present(viewController, animated: true)
    }
}
