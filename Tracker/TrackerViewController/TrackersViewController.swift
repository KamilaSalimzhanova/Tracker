import UIKit

class TrackersViewController: UIViewController {
    
    private var completedTrackersId: Set<UUID> = []
    private var complitedTrackers: [TrackerRecord] = []
    private var trackersForCurrentDate: [TrackerCategory] = []
    
    private var categories: [TrackerCategory] = []
    private var visibleTrackers: [TrackerCategory] = []
    private var searchedText: String = ""
    private lazy var trackerCategoryStore = TrackerCategoryStore(delegate: self, currentDate: currentDate, searchText: searchedText)
    private lazy var trackerRecordStore = TrackerRecordStore()
    private lazy var trackerStore = TrackerStore(delegate: self)
    let numberOfCellsInRow: Int = 2
    let height: Int = 148
    let horizontalSpacing: Int = 9
    let verticalSpacing: Int = 0
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
    var currentDate: Date? {
        didSet {
            updateTrackers(text: nil)
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "trackerCell")
        collectionView.register(TrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar: UISearchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("searchBarPlaceholder", comment: "Placeholder for a search bar")
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        searchBar.searchTextField.layer.cornerRadius = 18
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.delegate = self
        return searchBar
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
        emptyListText.text = NSLocalizedString("emptyTrackerStub.text", comment: "Text displayed on stub when tracker collection is empty")
        emptyListText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyListText.tintColor = .black
        emptyListText.translatesAutoresizingMaskIntoConstraints = false
        return emptyListText
    }()
    
    private lazy var stubView: UIView = {
        let stubView = UIView()
        stubView.sizeToFit()
        return stubView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("trackersViewController.title", comment: "Main title")
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .black
        return titleLabel
    }()
    
    private lazy var filterButton: UIButton = {
        let filterButton = UIButton(type: .system)
        filterButton.backgroundColor = .ypBlue
        filterButton.layer.cornerRadius = 12
        let filterButtonText = NSLocalizedString("filterButtonText", comment: "Text displayed on filter button")
        filterButton.setTitle(filterButtonText, for: .normal)
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        filterButton.titleLabel?.tintColor = .ypWhite
        filterButton.addTarget(
            self,
            action: #selector(filterButtonTapped),
            for: .touchUpInside
        )
        return filterButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.currentDate = Date()
        categories = trackerCategoryStore.getCategories()
        print(visibleTrackers)
        //sorted()
        addSubviews()
        setStubView()
        makeConstraints()
        setupNavigationBar()
        updateViewController()
    }
    
    
    private func sorted() {
        categories.forEach({ category in
            if category.trackers.isEmpty {
                print("empty tracker list in category \(category)")
            } else {
                visibleTrackers.append(category)
            }
        })
    }
    
    
    private func addSubviews() {
        [
            titleLabel,
            searchBar,
            stubView,
            collectionView,
            filterButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setStubView() {
        stubView.addSubview(emptyListImageView)
        stubView.addSubview(emptyListText)
        makeConstraintsStub()
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            stubView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            stubView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stubView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            stubView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
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
    
    private func updateTrackers(text: String?) {
        guard let currentDate = currentDate else {
            print("No current date selected")
            return
        }
        let weekday = DateFormatter.weekday(date: currentDate)
        print(weekday)
        let searchText = (text ?? "").lowercased()
        trackerCategoryStore.updateDateAndSearchText(weekday: weekday, searchedText: searchText)
        categories = trackerCategoryStore.getCategories()
        var searchedCategories: [TrackerCategory] = []
        for category in categories {
            var searchedTrackers: [Tracker] = []
            
            for tracker in category.trackers {
                if tracker.schedule.contains(weekday) {
                    print("Tracker is \(tracker)")
                    searchedTrackers.append(tracker)
                }
            }
            if !searchedTrackers.isEmpty {
                searchedCategories.append(TrackerCategory(title: category.title, trackers: searchedTrackers))
            }
            print("searcu categories are \(searchedCategories)")
            
        }
        print("Categories for this day \(searchedCategories)")
        visibleTrackers = searchedCategories
        print(visibleTrackers)
        collectionView.reloadData()
        updateViewController()
    }
    
    private func updateViewController() {
        if visibleTrackers.isEmpty {
            collectionView.isHidden = true
            stubView.isHidden = false
            filterButton.isHidden = true
        } else {
            collectionView.isHidden = false
            stubView.isHidden = true
            filterButton.isHidden = false
        }
    }
    
    private func setupNavigationBar() {
        self.navigationItem.title = nil
        let leftItem = UIImage(named: "Plus") ?? UIImage(systemName: "plus")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: leftItem,
            style: .plain,
            target: self,
            action: #selector(addTarget)
        )
        self.navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        let datePicker = setUpDatePicker()
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        self.navigationItem.rightBarButtonItem = datePickerItem
        self.navigationItem.rightBarButtonItem?.customView?.layer.cornerRadius = 8
    }
    
    private func setUpDatePicker() -> UIDatePicker {
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            datePicker.heightAnchor.constraint(equalToConstant: 34)])
        datePicker.addTarget(self,
                             action: #selector(datePickerValueChanged(_:)),
                             for: .valueChanged)
        
        return datePicker
    }
    
    @objc private func addTarget() {
        print("Add target")
        let viewController = TrackerTypeViewController()
        viewController.trackerViewController = self
        viewController.modalPresentationStyle = .popover
        self.present(viewController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        self.currentDate = selectedDate
    }
    
    @objc private func filterButtonTapped(){}
}


extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleTrackers[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCell", for: indexPath) as? TrackerCollectionViewCell
        guard let cell = cell else { return UICollectionViewCell() }
        let tracker = visibleTrackers[indexPath.section].trackers[indexPath.row]
        guard let date = currentDate else {
            print("No date")
            return UICollectionViewCell()
        }
        let isCompleted = trackerRecordStore.isCompletedTrackerRecords(id: tracker.trackerId, date: date)
        let completedDays = trackerRecordStore.completedTracker(id: tracker.trackerId)
        cell.configure(tracker: tracker, isCompleted: isCompleted, indexPath: indexPath, completedDays: completedDays, currentDate: currentDate)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! TrackerSupplementaryView
        if id == "header" {
            let header = visibleTrackers[indexPath.section].title
            view.configHeader(title: header)
        } else {
            view.configHeader(title: "")
        }
        return view
    }
}


extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat(height)
        let width = (CGFloat(collectionView.frame.width) - CGFloat((numberOfCellsInRow - 1)*horizontalSpacing)) / CGFloat(numberOfCellsInRow)
        let size = CGSize(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(horizontalSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(verticalSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: collectionView.frame.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}

extension TrackersViewController: TrackerCollectionViewCellProtocol {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        guard let date = currentDate else {
            print("No current date selected")
            return
        }
        let trackerRecord = TrackerRecord(trackerId: id, trackerDate: date)
        trackerRecordStore.saveTrackerRecord(trackerRecord: trackerRecord)
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        guard let date = currentDate else {
            print("No current date selected")
            return
        }
        trackerRecordStore.deleteRecord(id: id, currentDate: date)
    }
    
    func handlePinAction(indexPath: IndexPath) {
        let tracker = self.visibleTrackers[indexPath.section].trackers[indexPath.row]
        let targetCategoryTitle = "Закрепленные"
        
        if self.visibleTrackers[indexPath.section].title == targetCategoryTitle {
            handleUnpinAction(indexPath: indexPath)
        } else {
            if trackerCategoryStore.fetchAllCategories().first(where: { $0.title == targetCategoryTitle }) == nil {
                let newCategory = TrackerCategory(title: targetCategoryTitle, trackers: [])
                trackerCategoryStore.createCategory(newCategory)
            }
            let previousCategoryTitle = self.visibleTrackers[indexPath.section].title
            UserDefaults.standard.setValue(previousCategoryTitle, forKey: tracker.trackerId.uuidString)
            trackerCategoryStore.deleteTrackerFromCategory(tracker: tracker, with: self.visibleTrackers[indexPath.section].title)
            trackerCategoryStore.addTrackerToCategory(tracker: tracker, with: targetCategoryTitle)
            trackerStore.changePin(trackerId: tracker.trackerId, isPinned: true)
            updateTrackers(text: nil)
            collectionView.reloadData()
        }
    }
    
    func handleUnpinAction(indexPath: IndexPath){
        let tracker = self.visibleTrackers[indexPath.section].trackers[indexPath.row]
        let targetCategoryTitle = "Закрепленные"
        guard let originalCategoryTitle = UserDefaults.standard.string(forKey: tracker.trackerId.uuidString) else {
            print("No original category found for tracker with ID \(tracker.trackerId)")
            return
        }
        trackerCategoryStore.deleteTrackerFromCategory(tracker: tracker, with: targetCategoryTitle)
        if trackerCategoryStore.fetchAllCategories().first(where: { $0.title == originalCategoryTitle }) == nil {
            print("Original category \(originalCategoryTitle) does not exist. Creating it.")
            let newCategory = TrackerCategory(title: originalCategoryTitle, trackers: [])
            trackerCategoryStore.createCategory(newCategory)
        }
        trackerCategoryStore.addTrackerToCategory(tracker: tracker, with: originalCategoryTitle)
        UserDefaults.standard.removeObject(forKey: tracker.trackerId.uuidString)
        trackerStore.changePin(trackerId: tracker.trackerId, isPinned: false)
        updateTrackers(text: nil)
        collectionView.reloadData()
    }
}
extension TrackersViewController: HabbitCreateViewControllerProtocol {
    func createTracker(category: String, tracker: Tracker) {
        trackerCategoryStore.createCategoryAndTracker(tracker: tracker, with: category)
        categories = trackerCategoryStore.getCategories()
        visibleTrackers = categories
        collectionView.reloadData()
        updateTrackers(text: nil)
        print("Visible trackers after creation \(visibleTrackers)")
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateTrackers(text: searchBar.text)
    }
}

extension TrackersViewController: TrackerStoreDelegateProtocol {
    func addTracker(indexPath: IndexPath){
        collectionView.reloadData()
    }
}
