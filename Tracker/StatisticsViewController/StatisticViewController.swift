import Foundation
import UIKit

final class StatisticsViewController: UIViewController {
    
    var completedTrackers: [TrackerRecord] = []
    private let recordStore = TrackerRecordStore()
    private var trackers: [Tracker] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("statistics", comment: "Text displayed on statistics view controller title")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleStatisticLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.text = "0"
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .ypBlack
        label.text = NSLocalizedString("doneTrackersCount", comment: "")
        return label
    }()
    
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "StatisticsStub") ?? UIImage()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyImageView, emptyLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        print("Tracker record store \(recordStore.fetchRecords())")
        setupAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let trackersFinished = getNumberOfTrackerRecords()
        emptyCheck(trackersFinished: trackersFinished)
        titleStatisticLabel.text = String(trackersFinished)
        addGradientBorderTo(view: container)
    }
    
    func setValue(_ value: Int) {
        titleStatisticLabel.text = String(value)
    }
    
    private func getNumberOfTrackerRecords() -> Int {
        do {
            return try recordStore.getTrackerRecordCount()
        } catch {
            print("Error fetching tracker record count: \(error)")
            return 0
        }
    }
    
    private func setupAppearance() {
        view.addSubview(titleLabel)
        view.addSubview(container)
        container.addSubview(titleStatisticLabel)
        container.addSubview(subtitleLabel)
        view.addSubview(emptyStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            container.heightAnchor.constraint(equalToConstant: 90),
            
            titleStatisticLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleStatisticLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            
            emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    
    private func emptyCheck(trackersFinished: Int) {
        let isHidden: Bool = (trackersFinished > 0)
        emptyStackView.isHidden = isHidden
        container.isHidden = !isHidden
    }
    
    private func addGradientBorderTo(view: UIView) {
            let gradient = CAGradientLayer()
            gradient.cornerRadius = 16
            gradient.frame = view.bounds
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.colors = [
                UIColor(hex: "#007BFA").cgColor,
                UIColor(hex: "#46E69D").cgColor,
                UIColor(hex: "#FD4C49").cgColor
            ]
            
            let shape = CAShapeLayer()
            shape.lineWidth = 2
            shape.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: 16).cgPath
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = UIColor.clear.cgColor
            gradient.mask = shape
            
            view.layer.insertSublayer(gradient, at: 0)
        }
}
