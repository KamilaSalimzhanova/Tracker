import UIKit

protocol TrackerCollectionViewCellProtocol: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
    func handlePinAction(indexPath: IndexPath)
    func handleUnpinAction(indexPath: IndexPath)
    func handleEditAction(indexPath: IndexPath)
    func handleDeleteAction(indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell, UIContextMenuInteractionDelegate {
    
    var trackerId: UUID?
    var tracker: Tracker?
    var completedDays: Int = 0
    var indexPath: IndexPath?
    var isPinned = false
    var isCompletedToday: Bool = false
    var count = 0
    
    weak var delegate: TrackerCollectionViewCellProtocol?
    var trackerStore: TrackerStore?
    
    private let noteView: UIView = {
        let noteView = UIView()
        return noteView
    }()
    
    
    private let trackerView: UIView = {
        let trackerView = UIView()
        trackerView.layer.masksToBounds = true
        trackerView.layer.cornerRadius = 16
        trackerView.backgroundColor = UIColor.ypGreen
        return trackerView
    }()
    
    private let emojiView: UIView = {
        let emojiView = UIView()
        emojiView.backgroundColor = .ypWhite
        emojiView.layer.masksToBounds = true
        emojiView.layer.cornerRadius = 12
        emojiView.layer.opacity = 0.7
        return emojiView
    }()
    
    private let emoji: UILabel = {
        let emoji = UILabel()
        emoji.text = "😃"
        emoji.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return emoji
    }()
    
    private let trackerLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.text = "Поливать растения"
        trackerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        trackerLabel.textColor = .ypWhite
        return trackerLabel
    }()
    
    private let dayCountLabel: UILabel = {
        let dayCountLabel = UILabel()
        dayCountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: ""),
            0
        )
        dayCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dayCountLabel.textColor = .ypBlack
        return dayCountLabel
    }()
    
    private let dayCountButton: UIButton = {
        let dayCountButton = UIButton(type: .system)
        dayCountButton.backgroundColor = .ypGreen
        dayCountButton.layer.masksToBounds = true
        dayCountButton.layer.cornerRadius = 17
        dayCountButton.setImage(UIImage(named: "Plus button"), for: .normal)
        
        dayCountButton.tintColor = .white
        dayCountButton.addTarget(self,
                                 action: #selector(buttonTapped),
                                 for: .touchUpInside)
        dayCountButton.imageView?.contentMode = .scaleAspectFit
        dayCountButton.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        
        return dayCountButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
        trackerStore = TrackerStore(delegate: TrackersViewController())
        let contextMenu = UIContextMenuInteraction(delegate: self)
        trackerView.addInteraction(contextMenu)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(tracker: Tracker, isCompleted: Bool, indexPath: IndexPath, completedDays: Int, currentDate: Date?) {
        self.isCompletedToday = isCompleted
        self.trackerId = tracker.trackerId
        self.completedDays = completedDays
        self.indexPath = indexPath
        self.isPinned = tracker.isPinned
        let color = tracker.color
        
        trackerView.backgroundColor = color
        dayCountButton.backgroundColor = color
        
        trackerLabel.text = tracker.name
        emoji.text = tracker.emoji
        
        if isCompletedToday {
            trackerComplete()
        } else {
            trackerCompleteUndo()
        }
        
        guard let date = currentDate else {
            print("No date selected")
            return
        }
        
        if date > Date(){
            dayCountButton.isEnabled = false
        } else {
            dayCountButton.isEnabled = true
        }
    }
    private func addSubviews() {
        [
            noteView,
            trackerView,
            emojiView,
            emoji,
            trackerLabel,
            dayCountLabel,
            dayCountButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        self.addSubview(noteView)
        noteView.addSubview(trackerView)
        trackerView.addSubview(emojiView)
        trackerView.addSubview(emoji)
        trackerView.addSubview(trackerLabel)
        noteView.addSubview(dayCountLabel)
        self.addSubview(dayCountButton)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            noteView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            noteView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            noteView.topAnchor.constraint(equalTo: self.topAnchor),
            noteView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            trackerView.leadingAnchor.constraint(equalTo: noteView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: noteView.trailingAnchor),
            trackerView.topAnchor.constraint(equalTo: noteView.topAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiView.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiView.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            
            emoji.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            
            trackerLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            trackerLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            
            
            dayCountLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            dayCountLabel.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 16),
            
            dayCountButton.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            dayCountButton.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 8),
            dayCountButton.heightAnchor.constraint(equalToConstant: 34),
            dayCountButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func buttonTapped(){
        if isCompletedToday {
            UIView.animate(withDuration: 0.2, delay: 0) {
                guard let trackerId = self.trackerId, let indexPath = self.indexPath else {
                    print("TrackerID is null")
                    return
                }
                self.delegate?.uncompleteTracker(id: trackerId, at: indexPath)
                self.completedDays -= 1
                self.trackerCompleteUndo()
            }
        } else {
            UIView.animate(withDuration: 0.2, delay: 0) {
                guard let trackerId = self.trackerId, let indexPath = self.indexPath else {
                    print("TrackerID is null")
                    return
                }
                self.delegate?.completeTracker(id: trackerId, at: indexPath)
                self.completedDays += 1
                print(self.completedDays)
                self.trackerComplete()
            }
        }
        isCompletedToday = !isCompletedToday
    }
    func trackerComplete() {
        let buttonImage = UIImage(named: "Done")
        self.dayCountButton.layer.opacity = 0.7
        self.dayCountButton.setImage(buttonImage, for: .normal)
        self.dayCountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: ""),
            self.completedDays
        )
    }
    func getDayCount() -> String {
        self.dayCountLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: ""),
            self.completedDays
        )
        return dayCountLabel.text ?? ""
    }
    func trackerCompleteUndo() {
        let buttonImage = UIImage(named: "Plus button")
        self.dayCountButton.layer.opacity = 1
        self.dayCountButton.setImage(buttonImage, for: .normal)
        self.dayCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("numberOfDays", comment: ""), completedDays)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self, let indexPath = self.indexPath else {
                return UIMenu(title: "", children: [])
            }
            let pin = UIAction(title: NSLocalizedString("pin", comment: ""), image: UIImage(systemName: "pin")) { [self] _ in
                self.delegate?.handlePinAction(indexPath: indexPath)
            }
            
            let unpin = UIAction(title: NSLocalizedString("unpin", comment: ""), image: UIImage(systemName: "pin.slash")) { _ in
                self.delegate?.handlePinAction(indexPath: indexPath)
            }
            
            let edit = UIAction(title: NSLocalizedString("edit", comment: ""), image: UIImage(systemName: "pencil")) { _ in
                self.delegate?.handleEditAction(indexPath: indexPath)
            }
            
            let delete = UIAction(title: NSLocalizedString("delete", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.delegate?.handleDeleteAction(indexPath: indexPath)
            }
            
            let actions: [UIAction]
            if self.isPinned {
                actions = [unpin, edit, delete]
            } else {
                actions = [pin, edit, delete]
            }
            
            return UIMenu(title: "", children: actions)
        }
    }
    
    
}

