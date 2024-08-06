import UIKit

protocol HabbitCreateViewControllerProtocol: AnyObject {
    func createTracker(category: String, tracker: Tracker)
}

final class TrackerCreateViewController: UIViewController {
    weak var delegate: HabbitCreateViewControllerProtocol?
    let trackerTypeViewController: TrackerTypeViewController

    let regular: Bool
    var category: String?
    var trackerSchedule: [String] = []
    var trackerTitle = ""
    var scheduleTitle: String?
    var emojiSelected: String = ""
    var colorSelected: UIColor = .clear
    var selectedEmojiIndex: IndexPath?
    var selectedColorIndex: IndexPath?
    
    private let sectionHeader = ["Emoji","Цвет"]
    private let emoji: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    
    init(regular: Bool, trackerTypeViewController: TrackerTypeViewController) {
        self.regular = regular
        self.trackerTypeViewController = trackerTypeViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var categoryAndSchedule: [String] = {
        if regular {
            return ["Категория", "Расписание"]
        } else {
            return ["Категория"]
        }
    }()
    
    private lazy var collectionViewCellSize: Int = {
        if (view.frame.width - 32) / 6 >= 52 {
            return 52
        } else {
            return 48
        }
    }()
    
    private lazy var supplementaryViewCellSize: Int = 34
    private lazy var safeZoneCollectioView: Int = 58
    
    private lazy var collectionViewHeight: Int = {
        return sectionHeader.count * (supplementaryViewCellSize + safeZoneCollectioView) + emoji.count / 6 * collectionViewCellSize + colors.count / 6 * collectionViewCellSize
    }()
    
    private let colors: [UIColor] = [
        UIColor.rgbColors(red: 253, green: 76, blue: 73, alpha: 1),
        UIColor.rgbColors(red: 255, green: 136, blue: 30, alpha: 1),
        UIColor.rgbColors(red: 0, green: 123, blue: 250, alpha: 1),
        UIColor.rgbColors(red: 110, green: 68, blue: 254, alpha: 1),
        UIColor.rgbColors(red: 51, green: 207, blue: 105, alpha: 1),
        UIColor.rgbColors(red: 230, green: 109, blue: 212, alpha: 1),
        UIColor.rgbColors(red: 249, green: 212, blue: 212, alpha: 1),
        UIColor.rgbColors(red: 52, green: 167, blue: 254, alpha: 1),
        UIColor.rgbColors(red: 70, green: 230, blue: 157, alpha: 1),
        UIColor.rgbColors(red: 53, green: 52, blue: 124, alpha: 1),
        UIColor.rgbColors(red: 255, green: 103, blue: 77, alpha: 1),
        UIColor.rgbColors(red: 255, green: 153, blue: 204, alpha: 1),
        UIColor.rgbColors(red: 236, green: 196, blue: 139, alpha: 1),
        UIColor.rgbColors(red: 121, green: 148, blue: 245, alpha: 1),
        UIColor.rgbColors(red: 131, green: 44, blue: 241, alpha: 1),
        UIColor.rgbColors(red: 173, green: 86, blue: 218, alpha: 1),
        UIColor.rgbColors(red: 141, green: 214, blue: 230, alpha: 1),
        UIColor.rgbColors(red: 47, green: 208, blue: 88, alpha: 1)
    ]
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isScrollEnabled = true
        scrollView.scrollsToTop = true
        return scrollView
    }()
    
    private lazy var trackerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Новая привычка"
        titleLabel.tintColor = .ypBlack
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return titleLabel
    }()
    
    private lazy var newTrackerTextFieldView: UIView = {
        let newTrackerTextFieldView = UIView()
        newTrackerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        newTrackerTextFieldView.backgroundColor = UIColor.rgbColors(red: 230, green: 232, blue: 235, alpha: 0.3)
        newTrackerTextFieldView.layer.cornerRadius = 16
        return newTrackerTextFieldView
    }()
    
    private lazy var newTrackerNameTextField: UITextField = {
        let newTrackerNameTextField = UITextField()
        newTrackerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.rgbColors(red: 174, green: 175, blue: 180, alpha: 1),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        newTrackerNameTextField.attributedPlaceholder = NSAttributedString(string: "Введите название трекера", attributes: attributes)
        newTrackerNameTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        newTrackerNameTextField.backgroundColor = .none
        newTrackerNameTextField.addTarget(self,
                                          action: #selector(inputText(_ :)),
                                          for: .allEditingEvents)
        newTrackerNameTextField.delegate = self
        return newTrackerNameTextField
    }()
    
    lazy var categoryAndScheduleTableView: UITableView = {
        let categoryAndSchedule = UITableView()
        categoryAndSchedule.translatesAutoresizingMaskIntoConstraints = false
        categoryAndSchedule.layer.cornerRadius = 16
        categoryAndSchedule.backgroundColor = .ypWhite
        categoryAndSchedule.dataSource = self
        categoryAndSchedule.delegate = self
        categoryAndSchedule.register(TrackerCreateViewCell.self, forCellReuseIdentifier: "cell")
        categoryAndSchedule.rowHeight = 75
        categoryAndSchedule.separatorStyle = .singleLine
        categoryAndSchedule.separatorInset.left = 16
        categoryAndSchedule.separatorInset.right = 16
        categoryAndSchedule.separatorColor = .ypBlack
        categoryAndSchedule.isScrollEnabled = false
        return categoryAndSchedule
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypWhite
        button.backgroundColor = .rgbColors(red: 174, green: 175, blue: 180, alpha: 1)
        button.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypPink
        button.backgroundColor = .ypWhite
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypPink.cgColor
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStack: UIStackView = {
        let hStack = UIStackView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.distribution = .fillEqually
        hStack.backgroundColor = .none
        return hStack
    }()
    
    private lazy var emojiAndColors: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let emojiAndColors = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojiAndColors.translatesAutoresizingMaskIntoConstraints = false
        emojiAndColors.backgroundColor = .ypWhite
        emojiAndColors.register(EmojiAndColorCollectionViewCell.self, forCellWithReuseIdentifier: "emojiAndColors")
        emojiAndColors.register(EmojiAndColorsSupplementaryViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        emojiAndColors.dataSource = self
        emojiAndColors.delegate = self
        emojiAndColors.allowsMultipleSelection = false
        emojiAndColors.isScrollEnabled = false
        return emojiAndColors
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.category = regular ? "Важное" : "Нерегулярное событие"
        addSubviews()
        makeConstraints()
    }
    
    func reloadTable(){
        categoryAndScheduleTableView.reloadData()
    }
    
    private func addSubviews(){
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(createButton)
        view.addSubview(scrollView)
        scrollView.addSubview(trackerView)
        trackerView.addSubview(titleLabel)
        trackerView.addSubview(newTrackerTextFieldView)
        trackerView.addSubview(newTrackerNameTextField)
        trackerView.addSubview(categoryAndScheduleTableView)
        trackerView.addSubview(emojiAndColors)
        trackerView.addSubview(buttonStack)
    }
    
    private func makeConstraints(){
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            trackerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            trackerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            trackerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            trackerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            trackerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: trackerView.centerXAnchor),
            
            newTrackerTextFieldView.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 87),
            newTrackerTextFieldView.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 16),
            newTrackerTextFieldView.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -16),
            newTrackerTextFieldView.heightAnchor.constraint(equalToConstant: 75),
            
            newTrackerNameTextField.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 87),
            newTrackerNameTextField.leadingAnchor.constraint(equalTo: newTrackerTextFieldView.leadingAnchor, constant: 16),
            newTrackerNameTextField.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -16),
            newTrackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            categoryAndScheduleTableView.topAnchor.constraint(equalTo: newTrackerNameTextField.bottomAnchor, constant: 24),
            categoryAndScheduleTableView.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 16),
            categoryAndScheduleTableView.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -16),
            categoryAndScheduleTableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * categoryAndSchedule.count - 1)),
            
            emojiAndColors.topAnchor.constraint(equalTo: categoryAndScheduleTableView.bottomAnchor, constant: 8),
            emojiAndColors.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 16),
            emojiAndColors.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -16),
            emojiAndColors.heightAnchor.constraint(equalToConstant: CGFloat(collectionViewHeight)),
            
            buttonStack.topAnchor.constraint(equalTo: emojiAndColors.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 60),
            trackerView.bottomAnchor.constraint(equalTo: buttonStack.bottomAnchor)
        ])
    }
    
    func updateCreateButtonState() {
        let isValid = checkFormValidity()
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? UIColor.activeColor : UIColor.inactiveColor
    }
    
    private func checkFormValidity() -> Bool {
        if regular {
            return (!trackerTitle.isEmpty && !trackerSchedule.isEmpty && !emojiSelected.isEmpty && colorSelected != .clear)
        } else {
            return (!trackerTitle.isEmpty && !emojiSelected.isEmpty && colorSelected != .clear)
        }
    }
    
    
    @objc private func createTracker(){
        if !regular {
            trackerSchedule = [
                Weekdays.Monday.rawValue,
                Weekdays.Tuesday.rawValue,
                Weekdays.Wednesday.rawValue,
                Weekdays.Thursday.rawValue,
                Weekdays.Friday.rawValue,
                Weekdays.Saturday.rawValue,
                Weekdays.Sunday.rawValue
            ]
        }
        let schedule = trackerSchedule
        guard let category = self.category else { return }
        let tracker = Tracker(trackerId: UUID(), name: trackerTitle, color: colorSelected, emoji: emojiSelected, schedule: schedule)
        
        delegate?.createTracker(category: category, tracker: tracker)
        self.dismiss(animated: false)
        trackerTypeViewController.dismiss(animated: true)
        trackerSchedule = []
        scheduleTitle = nil
    }
    
    @objc private func cancel(){
        self.dismiss(animated: true)
    }
    
    @objc private func inputText(_ sender: UITextField) {
        let text = sender.text ?? ""
        trackerTitle = text
        print(text)
        self.updateCreateButtonState()
    }
}

extension TrackerCreateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryAndSchedule.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TrackerCreateViewCell
        guard let cell = cell else { return UITableViewCell() }
        cell.title.text = categoryAndSchedule[indexPath.row]
        if indexPath.row == 1 {
            if scheduleTitle != nil {
                cell.labelStackView.addArrangedSubview(cell.subTitle)
                cell.subTitle.text = scheduleTitle
            }
        } else {
            if category != nil {
                cell.labelStackView.addArrangedSubview(cell.subTitle)
                cell.subTitle.text = category
            }
        }
        cell.backgroundColor = UIColor.rgbColors(red: 230, green: 232, blue: 235, alpha: 0.3)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension TrackerCreateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            let viewController = ScheduleViewController()
            viewController.delegate = self
            viewController.modalPresentationStyle = .popover
            self.present(viewController, animated: true)
        } else {
            let viewController = CategoryViewController()
            viewController.modalPresentationStyle = .popover
            self.present(viewController, animated: true)
        }
        self.updateCreateButtonState()
    }
}

extension TrackerCreateViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionHeader.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return emoji.count
        case 1: return colors.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiAndColors", for: indexPath) as? EmojiAndColorCollectionViewCell
        guard let cell = cell else { return UICollectionViewCell() }
        let section = indexPath.section
        let emojiIsHidden = section == 0
        cell.configCell(isHidden: emojiIsHidden, text: emoji[indexPath.row], color: colors[indexPath.row])
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
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! EmojiAndColorsSupplementaryViewCell
        if id == "header" {
            headerView.configHeader(title: sectionHeader[indexPath.section])
        } else {
            headerView.configHeader(title: "")
        }
        return headerView
    }
}


extension TrackerCreateViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionViewCellSize, height: collectionViewCellSize)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: collectionView.frame.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiAndColorCollectionViewCell else {
            print("Cell is nil")
            return
        }
        UIView.animate(withDuration: 0.3) {
            if indexPath.section == 0 {
                if let previouslySelectedIndex = self.selectedEmojiIndex {
                    if previouslySelectedIndex == indexPath {
                        cell.backgroundColor = .ypWhite
                        self.emojiSelected = ""
                        self.selectedEmojiIndex = nil
                        self.updateCreateButtonState()
                        return
                    }
                    let previousCell = collectionView.cellForItem(at: previouslySelectedIndex) as? EmojiAndColorCollectionViewCell
                    previousCell?.backgroundColor = .ypWhite
                }
                cell.layer.cornerRadius = 16
                cell.clipsToBounds = true
                cell.backgroundColor = UIColor.rgbColors(red: 230, green: 232, blue: 235, alpha: 1)
                self.emojiSelected = self.emoji[indexPath.row]
                self.selectedEmojiIndex = indexPath
            } else if indexPath.section == 1 {
                if let previouslySelectedIndex = self.selectedColorIndex {
                    if previouslySelectedIndex == indexPath {
                        cell.layer.cornerRadius = 0
                        cell.layer.borderWidth = 0
                        self.colorSelected = .clear
                        self.selectedColorIndex = nil
                        self.updateCreateButtonState()
                        return
                    }
                    let previousCell = collectionView.cellForItem(at: previouslySelectedIndex) as? EmojiAndColorCollectionViewCell
                    previousCell?.layer.cornerRadius = 0
                    previousCell?.layer.borderWidth = 0
                }
                cell.layer.cornerRadius = 8
                cell.layer.borderWidth = 3
                cell.layer.borderColor = colorsBorder[indexPath.row].cgColor
                self.colorSelected = self.colors[indexPath.row]
                self.selectedColorIndex = indexPath
            }
            print(self.emojiSelected, self.colorSelected)
            self.updateCreateButtonState()
        }
    }
}

extension TrackerCreateViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerTitle = textField.text ?? ""
        print(trackerTitle)
        return true
    }
    
}
