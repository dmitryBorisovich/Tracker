import Foundation

enum CategoryError: Error {
    case duplicateName
    case addError
    case deleteError
    case editError
    
    var localizedDescription: String {
        switch self {
        case .duplicateName:
            return "Категория с таким именем уже существует"
        case .addError:
            return "Не удалось добавить новую категорию"
        case .deleteError:
            return "Не удалось удалить категорию"
        case .editError:
            return "Не удалось отредактировать категорию"
        }
    }
}
