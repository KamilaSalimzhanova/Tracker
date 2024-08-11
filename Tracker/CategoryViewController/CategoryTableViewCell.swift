import UIKit

class CategoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryTableViewCell"
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Checkmark")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        textLabel?.textColor = .ypBlack
        backgroundColor = .rgbColors(red: 230, green: 232, blue: 235, alpha: 0.3)
        selectionStyle = .none
        
        contentView.addSubview(checkmarkImageView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(category: TrackerCategory, isSelected: Bool) {
        textLabel?.text = category.title
        checkmarkImageView.isHidden = !isSelected
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 14.3),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 14.19),
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
