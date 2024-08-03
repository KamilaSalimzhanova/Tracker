import UIKit


final class TabBarViewController: UITabBarController {
    
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
        self.setupViewControllers()
        self.setupNavigationBar()
    }
    
    private func setupViewControllers() {
        
        let trackersViewController = TrackersViewController()
        let statisticViewController = StatisticViewController()
        
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
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: setUpDatePicket())
        self.navigationItem.rightBarButtonItem?.customView?.layer.masksToBounds = true
        self.navigationItem.rightBarButtonItem?.customView?.layer.cornerRadius = 8
    }
    
    private func setUpDatePicket() -> UIDatePicker {
        let date = Date().dateTimeString
        var datePicker: UIDatePicker = UIDatePicker()
        datePicker.backgroundColor = UIColor.white
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY" // Set your desired format here
        let formattedDate = dateFormatter.string(from: sender.date)
        print("Selected date: \(formattedDate)") // Do something with the formatted date
    }
    
    @objc func addTarget() {
        print("Add target")
    }
}
