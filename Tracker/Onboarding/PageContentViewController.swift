import UIKit

class PageContentViewController: UIViewController {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Onboarding1"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private lazy var mainLabel: UILabel = {
        let text = UILabel()
        text.text = "Отслеживайте только то, что хотите"
        text.tintColor = .ypBlack
        text.textAlignment = .center
        text.numberOfLines = 0
        text.font = .systemFont(ofSize: 32, weight: .bold)
        return text
    }()
    private lazy var switchButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        let buttonText = NSLocalizedString("onboardingButton.text", comment: "Text displayed on onboarding button")
        button.setTitle(buttonText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(switchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(imageName: String, text: String) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(named: imageName)
        mainLabel.text = text
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(imageView)
        view.addSubview(mainLabel)
        view.addSubview(switchButton)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        switchButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainLabel.heightAnchor.constraint(equalToConstant: 80),
            mainLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -306),
            mainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            switchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            switchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            switchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            switchButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    private func switchButtonTapped(){
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = TabBarViewController()
        }
    }
}
