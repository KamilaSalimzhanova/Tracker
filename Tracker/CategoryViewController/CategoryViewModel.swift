import Foundation

class CategoryViewModel {
    private let trackerCategoryStore: TrackerCategoryStore
    private var selectedCategoryIndex: Int?
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            self.updateUI?(categories)
        }
    }
    
    var updateUI: (([TrackerCategory]) -> Void)?
    var selectCategory: ((TrackerCategory) -> Void)?
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        loadCategories()
    }
    
    func viewDidLoad() {
        loadCategories()
    }
    
    
    func addCategory(withTitle title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        trackerCategoryStore.createCategory(newCategory)
        categories.append(newCategory)
        loadCategories()
    }
    
    func category(at index: Int) -> TrackerCategory {
        categories[index]
    }
    
    func numberOfCategories() -> Int {
        categories.count
    }
    
    func selectCategory(at index: Int) {
        let selectedCategory = categories[index]
        selectedCategoryIndex = index
        selectCategory?(selectedCategory)
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        return selectedCategoryIndex == index
    }
    
    private func loadCategories() {
        categories = trackerCategoryStore.fetchAllCategories().compactMap {
            trackerCategoryStore.decodingCategory(trackerCategoryCoreData: $0)
        }
        categories = categories.filter { $0.title != "Закрепленные" }
    }
}
