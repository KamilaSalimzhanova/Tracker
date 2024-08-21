import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let onboardingText1 = NSLocalizedString("mainLabelFirst.text", comment: "Text displayed on onboarding stage")
    let onboardingText2 = NSLocalizedString("mainLabelSecond.text", comment: "Text displayed on onboarding stage")

    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0

        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.lightGray

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.setViewControllers([PageContentViewController(imageName: "Onboarding1", text: onboardingText1)], direction: .forward, animated: true, completion: nil)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
              pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
              pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 18),
        pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -168)
        ])
    }
    
    // MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = indexOfViewController(viewController) else { return nil }
            
        let previousIndex = index - 1

        guard previousIndex >= 0 else {
            return createPageContentViewController(index: 1)
        }

        return createPageContentViewController(index: previousIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = indexOfViewController(viewController) else { return nil }
        let nextIndex = index + 1

        guard nextIndex < 2 else {
            return createPageContentViewController(index: 0)
        }

        return createPageContentViewController(index: nextIndex)
    }

    // MARK: - UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = indexOfViewController(currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
    
private func createPageContentViewController(index: Int) -> PageContentViewController {
        let imageName: String
        let text: String
        
        switch index {
        case 0:
            imageName = "Onboarding1"
            text = onboardingText1
        case 1:
            imageName = "Onboarding2"
            text = onboardingText2
        default:
            fatalError("Unexpected index")
        }
        
        return PageContentViewController(imageName: imageName, text: text)
    }
    
    private func indexOfViewController(_ viewController: UIViewController) -> Int? {
        if let pageContentViewController = viewController as? PageContentViewController {
            switch pageContentViewController.text {
            case onboardingText1:
                return 0
            case onboardingText2:
                return 1
            default:
                return nil
            }
        }
        return nil
    }
}
