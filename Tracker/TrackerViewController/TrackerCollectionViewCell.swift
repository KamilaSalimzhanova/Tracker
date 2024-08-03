import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    var isPlusButtonTapped: Bool = false
    var count = 0
    
    let noteView: UIView = {
        let noteView = UIView()
        return noteView
    }()
    
    
    let trackerView: UIView = {
        let trackerView = UIView()
        trackerView.layer.masksToBounds = true
        trackerView.layer.cornerRadius = 16
        trackerView.backgroundColor = UIColor.ypGreen
        return trackerView
    }()
    
    let emojiView: UIView = {
        let emojiView = UIView()
        emojiView.backgroundColor = .white
        emojiView.layer.masksToBounds = true
        emojiView.layer.cornerRadius = 12
        emojiView.layer.opacity = 0.7
        return emojiView
    }()
    
    let emoji: UILabel = {
        let emoji = UILabel()
        emoji.text = "😃"
        emoji.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return emoji
    }()
    
    let trackerLabel: UILabel = {
        let trackerLabel = UILabel()
        trackerLabel.text = "Поливать растения"
        trackerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        trackerLabel.textColor = .white
        return trackerLabel
    }()
    
    let dayCountLabel: UILabel = {
        let dayCountLabel = UILabel()
        dayCountLabel.text = "1 день"
        dayCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dayCountLabel.textColor = .black
        return dayCountLabel
    }()
    
    let dayCountButton: UIButton = {
        let dayCountButton = UIButton(type: .system)
        dayCountButton.backgroundColor = UIColor.ypGreen
        dayCountButton.layer.masksToBounds = true
        dayCountButton.layer.cornerRadius = 17
        let buttonImage = UIImage(named: "Plus button")
        dayCountButton.setImage(buttonImage, for: .normal)
        dayCountButton.tintColor = .white
        dayCountButton.addTarget(TrackerCollectionViewCell.self, action: #selector(buttonTapped), for: .touchUpInside)
        return dayCountButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    @objc func buttonTapped(){
        if !isPlusButtonTapped {
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.count += 1
                self.dayCountLabel.text = self.count.dayStringEnding()
                let buttonImage = UIImage(named: "Done")
                self.dayCountButton.layer.opacity = 0.7
                self.dayCountButton.setImage(buttonImage, for: .normal)
            }
        }else {
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.count -= 1
                self.dayCountLabel.text = self.count.dayStringEnding()
                let buttonImage = UIImage(named: "Plus button")
                self.dayCountButton.layer.opacity = 1
                self.dayCountButton.setImage(buttonImage, for: .normal)
            }
        }
        isPlusButtonTapped = !isPlusButtonTapped
    }
}





