import Foundation

final class CategoryViewModel {
    
    private let model: TrackerCategoryStore
    
    var onCategoriesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    private var selectedCategoryName: String?
    
    var selectedIndexPath: IndexPath? {
        guard let selectedCategoryName,
              let index = getCategoryIndex(for: selectedCategoryName)
        else { return nil }
        return IndexPath(row: index, section: 0)
    }
    
    init(model: TrackerCategoryStore, selectedCategoryName: String? = nil) {
        self.model = model
        self.model.delegate = self
        self.selectedCategoryName = selectedCategoryName
    }
    
    private func doWithErrorHandling(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch let error as CategoryError {
            onError?(error.localizedDescription)
        } catch {
            onError?("Неизвестная ошибка при выполнении операции")
        }
    }
    
    func addCategory(name: String) {
        doWithErrorHandling {
            try model.addNewCategory(TrackerCategory(name: name, trackers: []))
        }
    }
    
    func editCategory(at index: IndexPath, newName: String) {
        doWithErrorHandling {
            try model.editCategory(at: index, newName: newName)
        }
    }
    
    func deleteCategory(at index: IndexPath) {
        doWithErrorHandling {
            try model.deleteCategory(at: index)
        }
    }
    
    func countCategories() -> Int {
        model.countCategories() ?? 0
    }
    
    func getCategoryName(for index: IndexPath) -> String {
        let category = model.fetchCategory(at: index)
        return category.name ?? ""
    }
    
    func getCategoryIndex(for name: String) -> Int? {
        guard
            let categories = model.fetchCategories(),
            categories.count > 0
        else { return nil }
        return categories.firstIndex(where: { $0.name == name })
    }
    
    func selectCategory(name: String) {
        selectedCategoryName = name
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdate() {
        onCategoriesUpdated?()
    }
}
