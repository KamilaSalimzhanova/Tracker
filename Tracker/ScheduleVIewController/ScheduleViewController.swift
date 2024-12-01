import UIKit

final class ScheduleViewController: UIViewController {
    
    weak var delegate: TrackerCreateViewController?
    
    private var trackerSchedule: [String] = []
    private var scheduleSubtitle: [String] = []
    
    private let schedule = [
        Weekdays.Monday.rawValue,
        Weekdays.Tuesday.rawValue,
        Weekdays.Wednesday.rawValue,
        Weekdays.Thursday.rawValue,
        Weekdays.Friday.rawValue,
        Weekdays.Saturday.rawValue,
        Weekdays.Sunday.rawValue
    ]
    private let scheduleSubtitlesArray = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Расписание"
        titleLabel.tintColor = .ypBlack
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return titleLabel
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var scheduleTableView: UITableView = {
        let table = UITableView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        table.backgroundColor = .ypWhite
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = 75
        table.separatorInset.right = 16
        table.separatorInset.left = 16
        table.separatorColor = .rgbColors(red: 174, green: 175, blue: 180, alpha: 1)
        table.isScrollEnabled = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        addSubviews()
        makeConstraints()
    }
    
    private func addSubviews(){
        [
            titleLabel,
            scheduleTableView,
            readyButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func makeConstraints(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scheduleTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * schedule.count - 1)),
            
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 70)
            
        ])
    }
    
    @objc private func readyButtonTapped(){
        if let delegate = self.delegate {
            delegate.trackerSchedule = trackerSchedule
            delegate.scheduleTitle = scheduleSubtitle.joined(separator: ", ")
            delegate.categoryAndScheduleTableView.reloadData()
            delegate.updateCreateButtonState()
            self.dismiss(animated: true)
        }
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        schedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = schedule[indexPath.row]
        let switcher = UISwitch(frame: .zero)
        switcher.setOn(false, animated: true)
        switcher.tag = indexPath.row
        switcher.addTarget(self, action: #selector(switchToggle), for: .valueChanged)
        switcher.onTintColor = .ypBlue
        cell.accessoryView = switcher
        cell.backgroundColor = .rgbColors(red: 230, green: 232, blue: 235, alpha: 0.3)
        return cell
    }
    
    @objc private func switchToggle(_ sender: UISwitch) {
        let scheduleItem = schedule[sender.tag]
        let subtitleItem = scheduleSubtitlesArray[sender.tag]
        
        if sender.isOn {
            trackerSchedule.append(scheduleItem)
            scheduleSubtitle.append(subtitleItem)
            scheduleSubtitle = scheduleSubtitle.sorted { (a, b) -> Bool in
            return scheduleSubtitlesArray.firstIndex(of: a)! < scheduleSubtitlesArray.firstIndex(of: b)!
            }
        } else {
            trackerSchedule.removeAll { $0 == scheduleItem }
            scheduleSubtitle.removeAll { $0 == subtitleItem }
        }
    }

}


extension ScheduleViewController: UITableViewDelegate {}
