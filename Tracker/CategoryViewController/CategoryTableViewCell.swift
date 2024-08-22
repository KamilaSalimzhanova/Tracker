import UIKit

final class CategoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryTableViewCell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        textLabel?.textColor = .ypBlack
        backgroundColor = .rgbColors(red: 230, green: 232, blue: 235, alpha: 0.3)
        selectionStyle = .none
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(category: TrackerCategory) {
        textLabel?.text = category.title
    }
}
