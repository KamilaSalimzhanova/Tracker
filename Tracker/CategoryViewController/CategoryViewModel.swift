import Foundation

class CategoryViewModel {
    private let trackerCategoryStore: TrackerCategoryStore
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

    func loadCategories() {
        categories = trackerCategoryStore.fetchAllCategories().compactMap {
            trackerCategoryStore.decodingCategory(trackerCategoryCoreData: $0)
        }
    }

    func addCategory(withTitle title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        trackerCategoryStore.createCategory(newCategory)
        categories.append(newCategory)
        loadCategories()
    }
    
    func category(at index: Int) -> TrackerCategory {
        return categories[index]
    }
    
    func numberOfCategories() -> Int {
        return categories.count
    }

    func selectCategory(at index: Int) {
        let selectedCategory = categories[index]
        selectCategory?(selectedCategory)
    }
}
