//
//  ViewController.swift
//  Tracker
//
//  Created by kamila on 09.07.2024.
//

import UIKit

class TrackersViewController: UIViewController {
    

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.textColor = .black
        return titleLabel
    }()
    
    private lazy var searchField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Поиск"
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .black
        textField.backgroundColor = UIColor(named: "ColorDateBox") ?? UIColor.gray
        textField.layer.cornerRadius = 8
        let magnifyingGlassImageView = UIImageView(image: UIImage(named: "MagnifyingGlass"))
        magnifyingGlassImageView.contentMode = .scaleAspectFit
        magnifyingGlassImageView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 53, height: 24))
        magnifyingGlassImageView.center = CGPoint(x: paddingView.frame.width / 2, y: paddingView.frame.height / 2)
        paddingView.addSubview(magnifyingGlassImageView)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Stub"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let plusButton = UIButton(type: .custom)
        plusButton.setImage(UIImage(named: "Plus"), for: .normal)
        plusButton.frame = CGRect(x: 0, y: 0, width: 42, height: 42)
        plusButton.addTarget(self, action: #selector(addTracker), for: .touchDown)
        return plusButton
    }()
    
    private lazy var dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "ColorDateBox") ?? UIColor.gray
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.titleLabel?.textAlignment = .center
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.setTitle(getFormattedDate(), for: .normal)
        button.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        addSubviews()
        makeConstraints()
    }
    
    
    private func setupNavBar() {
        let plusBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.leftBarButtonItem = plusBarButtonItem
        
        let dateBarButtonItem = UIBarButtonItem(customView: dateButton)
        navigationItem.rightBarButtonItem = dateBarButtonItem
    }
    
    
    private func getFormattedDate(from date: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: date)
    }
    
    private func addSubviews() {
        [
            titleLabel,
            searchField,
            stubImageView,
            stubLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchField.widthAnchor.constraint(equalToConstant: 343),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            stubImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            stubImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 147),
            
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: stubImageView.centerXAnchor),
        ])
    }
    
    @objc private func addTracker() {
        print("Добавить трекер")
    }
    
    
    @objc private func dateButtonTapped() {
        let datePickerVC = DatePickerViewController()
        datePickerVC.modalPresentationStyle = .popover
        datePickerVC.preferredContentSize = CGSize(width: 320, height: 300)
        
        if let popoverController = datePickerVC.popoverPresentationController {
            popoverController.sourceView = dateButton
            popoverController.sourceRect = dateButton.bounds
            popoverController.permittedArrowDirections = .up
            popoverController.backgroundColor = .white
            
            datePickerVC.onDateSelected = { [weak self] selectedDate in
                self?.dateButton.setTitle(self?.getFormattedDate(from: selectedDate), for: .normal)
            }
            
            present(datePickerVC, animated: true)
        }
    }
    
    
}

