import Foundation
import UIKit

class ClaudeService {
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!

    func analyzeMeal(image: UIImage) async throws -> MealAnalysis {
        let apiKey = UserDefaults.standard.string(forKey: "claude_api_key") ?? ""
        guard !apiKey.isEmpty else {
            throw ClaudeError.missingAPIKey
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ClaudeError.imageEncodingFailed
        }
        let base64Image = imageData.base64EncodedString()

        let requestBody: [String: Any] = [
            "model": "claude-opus-4-8",
            "max_tokens": 1024,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": """
                            Analizza questa immagine di un pasto e fornisci una lista dettagliata di tutti gli ingredienti visibili con le loro calorie stimate.

                            Rispondi SOLO con un oggetto JSON valido, senza testo aggiuntivo, nel seguente formato:
                            {
                                "mealName": "Nome del pasto in italiano",
                                "totalCalories": 500,
                                "ingredients": [
                                    {
                                        "name": "Nome ingrediente",
                                        "quantity": "Quantità stimata (es. 150g, 1 porzione)",
                                        "calories": 200
                                    }
                                ],
                                "notes": "Note aggiuntive opzionali sull'analisi nutrizionale"
                            }

                            Assicurati che tutti i valori calorici siano numeri interi. La somma delle calorie degli ingredienti deve approssimare totalCalories.
                            """
                        ]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.apiError("Risposta non valida dal server")
        }

        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw ClaudeError.apiError(errorResponse.error.message)
            }
            throw ClaudeError.apiError("HTTP \(httpResponse.statusCode)")
        }

        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        guard let textContent = claudeResponse.content.first(where: { $0.type == "text" })?.text else {
            throw ClaudeError.noContent
        }

        let jsonString = extractJSON(from: textContent)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw ClaudeError.parsingFailed("Conversione stringa fallita")
        }

        do {
            return try JSONDecoder().decode(MealAnalysis.self, from: jsonData)
        } catch {
            throw ClaudeError.parsingFailed(error.localizedDescription)
        }
    }

    private func extractJSON(from text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        if let start = cleaned.firstIndex(of: "{"),
           let end = cleaned.lastIndex(of: "}") {
            return String(cleaned[start...end])
        }
        return cleaned
    }
}

enum ClaudeError: LocalizedError {
    case missingAPIKey
    case imageEncodingFailed
    case apiError(String)
    case noContent
    case parsingFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Chiave API mancante. Vai in Impostazioni per configurarla."
        case .imageEncodingFailed:
            return "Impossibile elaborare l'immagine selezionata."
        case .apiError(let message):
            return "Errore API: \(message)"
        case .noContent:
            return "Nessuna risposta ricevuta dall'analisi."
        case .parsingFailed(let details):
            return "Errore nell'analisi della risposta: \(details)"
        }
    }
}

private struct ClaudeResponse: Codable {
    let content: [ContentBlock]

    struct ContentBlock: Codable {
        let type: String
        let text: String?
    }
}

private struct APIErrorResponse: Codable {
    let error: APIError

    struct APIError: Codable {
        let type: String
        let message: String
    }
}
