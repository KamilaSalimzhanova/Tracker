import UIKit

protocol NewCategoryViewControllerDelegateProtocol: AnyObject {
    func categoryScreen(_ screen: NewCategoryViewController, didAddCategoryWithTitle title: String)
}


final class NewCategoryViewController: UIViewController {
    
    var categoryTitle: String = ""
    weak var delegate: NewCategoryViewControllerDelegateProtocol?
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Новая категория"
        titleLabel.tintColor = .ypBlack
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return titleLabel
    }()
    
    private lazy var newCategoryTextFieldView: UIView = {
        let newCategoryTextFieldView = UIView()
        newCategoryTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        newCategoryTextFieldView.backgroundColor = UIColor.rgbColors(red: 230, green: 232, blue: 235, alpha: 0.3)
        newCategoryTextFieldView.layer.cornerRadius = 16
        return newCategoryTextFieldView
    }()
    
    private lazy var newCategoryNameTextField: UITextField = {
        let newCategoryNameTextField = UITextField()
        newCategoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.rgbColors(red: 174, green: 175, blue: 180, alpha: 1),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        newCategoryNameTextField.attributedPlaceholder = NSAttributedString(string: "Введите название категории", attributes: attributes)
        newCategoryNameTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        newCategoryNameTextField.backgroundColor = .none
        newCategoryNameTextField.addTarget(self,
                                           action: #selector(inputText(_ :)),
                                           for: .allEditingEvents)
        newCategoryNameTextField.delegate = self
        return newCategoryNameTextField
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addSubviews()
        makeConstraints()
    }
    
    private func addSubviews(){
        [
            titleLabel,
            newCategoryTextFieldView,
            newCategoryNameTextField,
            readyButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func makeConstraints(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            newCategoryTextFieldView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            newCategoryTextFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newCategoryTextFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newCategoryTextFieldView.heightAnchor.constraint(equalToConstant: 75),
            
            newCategoryNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            newCategoryNameTextField.leadingAnchor.constraint(equalTo: newCategoryTextFieldView.leadingAnchor, constant: 16),
            newCategoryNameTextField.trailingAnchor.constraint(equalTo: newCategoryNameTextField.trailingAnchor, constant: -16),
            newCategoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func updateReadyButtonState() {
        let isValid = !categoryTitle.isEmpty
        readyButton.isEnabled = isValid
        readyButton.backgroundColor = isValid ? UIColor.activeColor : UIColor.inactiveColor
    }
    
    @objc private func inputText(_ sender: UITextField) {
        let text = sender.text ?? ""
        categoryTitle = text
        print(categoryTitle)
        self.updateReadyButtonState()
    }
    
    @objc private func readyButtonTapped() {
        delegate?.categoryScreen(self, didAddCategoryWithTitle: categoryTitle)
        self.dismiss(animated: false)
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        categoryTitle = textField.text ?? ""
        print(categoryTitle)
        return true
    }
}
