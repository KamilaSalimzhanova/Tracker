import Foundation
import UIKit

final class TrackerTypeViewController: UIViewController {
    
    weak var trackerViewController: TrackersViewController?
    
    private lazy var habbitButton: UIButton = {
        let habbitButton = UIButton(type: .system)
        habbitButton.layer.cornerRadius = 16
        habbitButton.setTitle("Привычка", for: .normal)
        habbitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habbitButton.tintColor = .ypWhite
        habbitButton.backgroundColor = .ypBlack
        habbitButton.addTarget(self, action: #selector(habbitButtonTapped), for: .touchUpInside)
        return habbitButton
    }()


    private lazy var notRegularCaseButton: UIButton = {
        let notRegularCaseButton = UIButton(type: .system)
        notRegularCaseButton.layer.cornerRadius = 16
        notRegularCaseButton.backgroundColor = .ypBlack
        notRegularCaseButton.tintColor = .ypWhite
        notRegularCaseButton.setTitle("Нерегулярное событие", for: .normal)
        notRegularCaseButton.addTarget(self, action: #selector(irregularButtonTapped), for: .touchUpInside)
        return notRegularCaseButton
        
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Создание трекера"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return titleLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        addSubviews()
        setConstrains()
        
    }

    func addSubviews(){
        [
            titleLabel,
            habbitButton,
            notRegularCaseButton
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    func setConstrains(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        
            habbitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habbitButton.heightAnchor.constraint(equalToConstant: 60),
            habbitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habbitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            notRegularCaseButton.leadingAnchor.constraint(equalTo: habbitButton.leadingAnchor),
            notRegularCaseButton.heightAnchor.constraint(equalToConstant: 60),
            notRegularCaseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            notRegularCaseButton.topAnchor.constraint(equalTo: habbitButton.bottomAnchor, constant: 16)
        ])
    }
    
    @objc private func habbitButtonTapped() {
        let viewController = TrackerCreateViewController(regular: true, trackerTypeViewController: self)
        viewController.delegate = trackerViewController
        viewController.modalPresentationStyle = .popover
        self.present(viewController, animated: true)
    }
    
    @objc private func irregularButtonTapped() {
        let viewController = TrackerCreateViewController(regular: false, trackerTypeViewController: self)
        viewController.delegate = trackerViewController
        viewController.modalPresentationStyle = .popover
        self.present(viewController, animated: true)
    }
}
