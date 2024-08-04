import UIKit

class EmojiAndColorCollectionViewCell: UICollectionViewCell {
    
    lazy var emoji: UILabel = {
        let emoji = UILabel()
        emoji.text = "😄"
        emoji.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return emoji
    }()
    
    lazy var color: UIView = {
        let color = UIView()
        color.layer.cornerRadius = 8
        color.clipsToBounds = true
        return color
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstrains()
    }
    

    private func addSubviews() {
        [
            emoji,
            color,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
    private func makeConstrains(){
        NSLayoutConstraint.activate([
            emoji.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            color.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            color.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            color.heightAnchor.constraint(equalToConstant: 40),
            color.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

