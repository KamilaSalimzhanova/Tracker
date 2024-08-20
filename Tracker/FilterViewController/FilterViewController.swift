import UIKit

enum FilterOption: String {
    case allTrackers = "Все трекеры"
    case todayTrackers = "Трекеры на сегодня"
    case completed = "Завершённые"
    case incomplete = "Незавершённые"
}

class FilterViewController: UIViewController {
        
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Фильтры"
        titleLabel.tintColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return titleLabel
    }()
    
    var selectedFilter: FilterOption = .allTrackers
    var filterSelectionHandler: ((FilterOption) -> Void)?
    
    private let filterOptions: [FilterOption] = [.allTrackers, .todayTrackers, .completed, .incomplete]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.backgroundColor = .ypWhite
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FilterViewCell.self, forCellReuseIdentifier: FilterViewCell.reuseIdentifier)
        tableView.rowHeight = 75
        tableView.separatorInset.right = 16
        tableView.separatorInset.left = 16
        tableView.separatorColor = .rgbColors(red: 174, green: 175, blue: 180, alpha: 1)
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
    }
    
    private func setupTableView() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
    }
}

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterViewCell.reuseIdentifier, for: indexPath) as! FilterViewCell
        let filter = filterOptions[indexPath.row]
        cell.configure(filterTitle: filter.rawValue)
        cell.accessoryType = (filter == selectedFilter) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = filterOptions[indexPath.row]
        filterSelectionHandler?(selectedOption)
        dismiss(animated: true, completion: nil)
    }
}
