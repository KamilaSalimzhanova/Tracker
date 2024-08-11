import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func categoryScreen(_ screen: CategoryViewController, didSelectedCategory category: TrackerCategory)
}

final class CategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewControllerDelegate?
    private var categories: [TrackerCategory] = []
    private var trackerCategoryStore: TrackerCategoryStore?
    private var selectedCategoryTitle: String?
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Категория"
        titleLabel.tintColor = .ypBlack
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return titleLabel
    }()
    
    private lazy var stubView: UIView = {
        let stubView = UIView()
        stubView.sizeToFit()
        return stubView
    }()
    
    private lazy var emptyListImageView: UIImageView = {
        var emptyList = UIImageView()
        let emptyListStub = UIImage(named: "Stub") ?? UIImage()
        emptyList.image = emptyListStub
        emptyList.translatesAutoresizingMaskIntoConstraints = false
        return emptyList
    }()
    
    private lazy var emptyListText: UILabel = {
        let emptyListText = UILabel()
        emptyListText.text = "Привычки и события можно объединить по смыслу"
        emptyListText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyListText.tintColor = .black
        emptyListText.translatesAutoresizingMaskIntoConstraints = false
        return emptyListText
    }()
    
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private var categoryTitles: [String] {
        let trackersViewController = TrackersViewController()
        return trackersViewController.getCategories()
    }
    
    private lazy var categoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .ypWhite
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        let trackers = TrackersViewController()
        trackerCategoryStore = TrackerCategoryStore(delegate: trackers, currentDate: trackers.currentDate, searchText: "")
        addSubviews()
        setStubView()
        makeConstraints()
        loadCategories()
    }
    
    private func addSubviews(){
        [
            titleLabel,
            stubView,
            categoryTableView,
            addCategoryButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func makeConstraints(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stubView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            stubView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stubView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            stubView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            categoryTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setStubView() {
        stubView.addSubview(emptyListImageView)
        stubView.addSubview(emptyListText)
        stubView.isHidden = true
        makeConstraintsStub()
    }
    
    private func makeConstraintsStub() {
        NSLayoutConstraint.activate([
            emptyListImageView.centerXAnchor.constraint(equalTo: stubView.centerXAnchor),
            emptyListImageView.centerYAnchor.constraint(equalTo: stubView.centerYAnchor, constant: -25),
            emptyListImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyListImageView.widthAnchor.constraint(equalToConstant: 80),
            
            emptyListText.centerXAnchor.constraint(equalTo: stubView.centerXAnchor),
            emptyListText.topAnchor.constraint(equalTo: emptyListImageView.bottomAnchor, constant: 8)
        ])
    }
    private func updateMainScreenContent() {
        let hasCategories = !categories.isEmpty
        categoryTableView.isHidden = !hasCategories
        stubView.isHidden = hasCategories
    }
    
    private func loadCategories() {
        categories = trackerCategoryStore?.getCategories() ?? []
        print(categories)
        updateMainScreenContent()
        categoryTableView.reloadData()
    }
    @objc private func addCategoryButtonTapped() {
        let viewController = NewCategoryViewController()
        viewController.delegate = self
        viewController.modalPresentationStyle = .popover
        self.present(viewController, animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(categories.count)
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath) as! CategoryTableViewCell
        let category = categories[indexPath.row]
        let isSelected = category.title == selectedCategoryTitle
        cell.configure(category: category, isSelected: isSelected)
        print(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        selectedCategoryTitle = selectedCategory.title
        tableView.reloadData()
        print(selectedCategory.title)
        delegate?.categoryScreen(self, didSelectedCategory: selectedCategory)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true)
        }
    }
}

extension CategoryViewController: UITableViewDelegate {}

extension CategoryViewController: NewCategoryViewControllerDelegateProtocol {
    func categoryScreen(_ screen: NewCategoryViewController, didAddCategoryWithTitle title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        trackerCategoryStore?.createCategory(newCategory)
        categories = trackerCategoryStore?.getCategories() ?? []
        print("New category added: \(title)")
        print("Updated categories: \(categories)")
        updateMainScreenContent()
        categoryTableView.reloadData()
    }
}
