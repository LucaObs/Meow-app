import SwiftUI

struct ResultView: View {
    let analysis: MealAnalysis

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(analysis.mealName)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack {
                        Text("Totale calorie")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(analysis.totalCalories) kcal")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Riepilogo")
            }

            Section {
                ForEach(analysis.ingredients) { ingredient in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ingredient.name)
                                .font(.body)
                                .fontWeight(.medium)
                            Text(ingredient.quantity)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(ingredient.calories) kcal")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 2)
                }
            } header: {
                Text("Ingredienti (\(analysis.ingredients.count))")
            }

            if let notes = analysis.notes, !notes.isEmpty {
                Section {
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Note Nutrizionali")
                }
            }
        }
        .navigationTitle("Analisi Pasto")
        .navigationBarTitleDisplayMode(.inline)
    }
}
