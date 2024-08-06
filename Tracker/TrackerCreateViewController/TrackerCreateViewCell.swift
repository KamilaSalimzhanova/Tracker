import UIKit

class TrackerCreateViewCell: UITableViewCell {
    
    lazy var labelStackView: UIStackView = {
        let vStack = UIStackView()
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = 2
        vStack.distribution = .fillEqually
        return vStack
    }()
    
    lazy var title: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Категория"
        title.textColor = .ypBlack
        title.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return title
    }()
    
    lazy var subTitle: UILabel = {
        let subTitle = UILabel()
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        subTitle.textColor = UIColor.rgbColors(red: 174, green: 175, blue: 180, alpha: 1)
        subTitle.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return subTitle
    }()
    
    lazy var accessoryImageView: UIImageView = {
        let defaultImage = UIImage(named: "Chevron") ?? UIImage(systemName: "chevron.right")
        let imageView = UIImageView(image: defaultImage)
        imageView.tintColor = UIColor.rgbColors(red: 174, green: 175, blue: 180, alpha: 1)
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        labelStackView.addArrangedSubview(title)
        addSubiews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubiews(){
        contentView.addSubview(labelStackView)
    }
    
    private func makeConstraints(){
        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelStackView.heightAnchor.constraint(equalToConstant: 46),
            labelStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
