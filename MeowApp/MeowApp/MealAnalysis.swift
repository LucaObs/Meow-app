import Foundation

struct MealAnalysis: Codable {
    let mealName: String
    let totalCalories: Int
    let ingredients: [Ingredient]
    let notes: String?
}

struct Ingredient: Identifiable, Codable {
    var id = UUID()
    let name: String
    let quantity: String
    let calories: Int

    enum CodingKeys: String, CodingKey {
        case name, quantity, calories
    }
}
