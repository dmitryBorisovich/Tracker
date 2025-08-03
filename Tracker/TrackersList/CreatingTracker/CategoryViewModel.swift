import Foundation

final class CategoryViewModel {
    
    private let model: TrackerCategoryStore
    
    var onCategoriesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    private var selectedCategoryName: String?
    
    var categories: [TrackerCategory] = [] {
        didSet {
            print("обновляем табличку.......")
            onCategoriesUpdated?()
        }
    }
    
    init(model: TrackerCategoryStore) {
        self.model = model
        loadCategories()
    }
    
    private func loadCategories() {
        guard let fetchedObjects = model.fetchCategories() else { return }
        categories = fetchedObjects.map { TrackerCategory(name: $0.name ?? "", trackers: []) }
    }
    
    func addCategory(name: String) {
        let newCategory = TrackerCategory(name: name, trackers: [])
        do {
            try model.addNewCategory(newCategory)
            categories.append(newCategory)
        } catch {
            onError?("Не удалось добавить категорию")
        }
    }
    
    func editCategory(oldName: String, newName: String) {
        guard let index = categories.firstIndex(where: { $0.name == oldName }) else {
            onError?("Категория не найдена")
            return
        }
        do {
            try model.editCategory(oldName, newName: newName)
            categories.remove(at: index)
            categories.append(TrackerCategory(name: newName, trackers: []))
        } catch {
            onError?("Не удалось отредактировать категорию")
        }
    }
    
    func deleteCategory(at index: Int) {
        let categoryToDelete = categories[index]
        do {
            try model.deleteCategory(categoryToDelete.name)
            categories.remove(at: index)
        } catch {
            onError?("Не удалось удалить категорию")
        }
    }
    
    func countCategories() -> Int {
        model.countCategories() ?? 0
    }
    
    func getCategoryName(for index: IndexPath) -> String {
        guard index.row < categories.count else {
            return ""
        }
        return categories[index.row].name
        // TODO: Fatal error: Index out of range
    }
    
    func getCategoryIndex(for name: String) -> Int? {
        categories.firstIndex(where: { $0.name == name })
    }
}

//extension CategoryViewModel: TrackerCategoryStoreDelegate {
//    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
//        tableView.performBatchUpdates {
//            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
//            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
//            tableView.insertRows(at: insertedIndexPaths, with: .automatic)
//            tableView.deleteRows(at: deletedIndexPaths, with: .fade)
//        }
//    }
//}
