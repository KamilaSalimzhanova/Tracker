import UIKit

final class CategoryViewController: UIViewController {

    weak var delegate: TrackerCreateViewController?
    private var category: String = ""
    private var selectedCategories: [String] = []
    private let checkmarkImage = UIImage(named: "checkmark")
    

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
        let table = UITableView()
        table.layer.cornerRadius = 16
        table.backgroundColor = .ypWhite
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "categoriesTableCell")
        table.rowHeight = 75
        table.separatorInset.right = 16
        table.separatorInset.left = 16
        table.separatorColor = .rgbColors(red: 174, green: 175, blue: 180, alpha: 1)
        table.isScrollEnabled = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addSubviews()
        if categoryTitles.isEmpty { setStubView() }
        makeConstraints()
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
            
            categoryTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * categoryTitles.count - 1)),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setStubView() {
        stubView.addSubview(emptyListImageView)
        stubView.addSubview(emptyListText)
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
    
    @objc private func addCategoryButtonTapped() {}
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesTableCell", for: indexPath)
        cell.textLabel?.text = categoryTitles[indexPath.row]
        cell.backgroundColor = .rgbColors(red: 230, green: 232, blue: 235, alpha: 0.3)
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
