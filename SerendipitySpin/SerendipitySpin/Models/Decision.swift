import Foundation

enum DecisionCategory: String, CaseIterable {
    case travel = "Travel"
    case food = "Food"
    case movies = "Movies"
    case entertainment = "Entertainment"
    
    var icon: String {
        switch self {
        case .travel:
            return "airplane"
        case .food:
            return "fork.knife"
        case .movies:
            return "film"
        case .entertainment:
            return "gamecontroller"
        }
    }
}

struct Decision: Codable {
    let id: UUID
    let title: String
    let category: String
    let details: String?
    let date: Date
    
    init(title: String, category: String, details: String? = nil) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.details = details
        self.date = Date()
    }
} 