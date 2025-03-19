import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let decisionsKey = "userDecisions"
    private let historyKey = "decisionHistory"
    private let defaults = UserDefaults.standard
    
    private init() {
        // 如果没有决策数据，添加一些默认数据
        if getDecisions().isEmpty {
            addDefaultDecisions()
        }
    }
    
    // MARK: - 决策数据管理
    
    func getDecisions(for category: DecisionCategory? = nil) -> [Decision] {
        guard let data = defaults.data(forKey: decisionsKey) else { return [] }
        do {
            let decisions = try JSONDecoder().decode([Decision].self, from: data)
            if let category = category {
                return decisions.filter { $0.category == category.rawValue }
            }
            return decisions
        } catch {
            print("Error decoding decisions: \(error)")
            return []
        }
    }
    
    func saveDecision(_ decision: Decision) {
        var decisions = getDecisions()
        decisions.append(decision)
        saveAllDecisions(decisions)
    }
    
    func deleteDecision(withID id: UUID) {
        var decisions = getDecisions()
        decisions.removeAll { $0.id == id }
        saveAllDecisions(decisions)
    }
    
    private func saveAllDecisions(_ decisions: [Decision]) {
        do {
            let data = try JSONEncoder().encode(decisions)
            defaults.set(data, forKey: decisionsKey)
        } catch {
            print("Error encoding decisions: \(error)")
        }
    }
    
    // MARK: - 历史记录管理
    
    func getHistory() -> [Decision] {
        guard let data = defaults.data(forKey: historyKey) else { return [] }
        do {
            return try JSONDecoder().decode([Decision].self, from: data)
        } catch {
            print("Error decoding history: \(error)")
            return []
        }
    }
    
    func saveToHistory(_ decision: Decision) {
        var history = getHistory()
        history.append(decision)
        do {
            let data = try JSONEncoder().encode(history)
            defaults.set(data, forKey: historyKey)
        } catch {
            print("Error encoding history: \(error)")
        }
    }
    
    func clearHistory() {
        defaults.removeObject(forKey: historyKey)
    }
    
    func deleteHistoryItem(withID id: UUID) {
        var history = getHistory()
        history.removeAll { $0.id == id }
        do {
            let data = try JSONEncoder().encode(history)
            defaults.set(data, forKey: historyKey)
        } catch {
            print("Error encoding history: \(error)")
        }
    }
    
    // MARK: - 默认数据
    
    private func addDefaultDecisions() {
        let travelDecisions = [
            Decision(title: "Paris, France", category: DecisionCategory.travel.rawValue, details: "Visit the Eiffel Tower and enjoy French cuisine"),
            Decision(title: "Tokyo, Japan", category: DecisionCategory.travel.rawValue, details: "Explore the bustling city and traditional temples"),
            Decision(title: "New York City, USA", category: DecisionCategory.travel.rawValue, details: "See Times Square and Central Park")
        ]
        
        let foodDecisions = [
            Decision(title: "Italian Restaurant", category: DecisionCategory.food.rawValue, details: "Try authentic pasta and pizza"),
            Decision(title: "Sushi Bar", category: DecisionCategory.food.rawValue, details: "Fresh sushi and sashimi"),
            Decision(title: "Steakhouse", category: DecisionCategory.food.rawValue, details: "Premium cuts of beef and fine wine")
        ]
        
        let movieDecisions = [
            Decision(title: "Action Movie", category: DecisionCategory.movies.rawValue, details: "Thrilling stunts and exciting plot"),
            Decision(title: "Romantic Comedy", category: DecisionCategory.movies.rawValue, details: "Light-hearted romance with humor"),
            Decision(title: "Sci-Fi Adventure", category: DecisionCategory.movies.rawValue, details: "Futuristic worlds and technology")
        ]
        
        let entertainmentDecisions = [
            Decision(title: "Board Game Night", category: DecisionCategory.entertainment.rawValue, details: "Strategic games with friends"),
            Decision(title: "Concert", category: DecisionCategory.entertainment.rawValue, details: "Live music performance"),
            Decision(title: "Hiking Trip", category: DecisionCategory.entertainment.rawValue, details: "Outdoor adventure in nature")
        ]
        
        let allDecisions = travelDecisions + foodDecisions + movieDecisions + entertainmentDecisions
        saveAllDecisions(allDecisions)
    }
} 