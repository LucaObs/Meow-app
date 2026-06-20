import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var analysis: MealAnalysis?
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    @State private var showingResult = false
    @State private var showingSettings = false

    private let claudeService = ClaudeService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 320)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .frame(height: 220)
                            VStack(spacing: 12) {
                                Image(systemName: "fork.knife.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.orange)
                                Text("Seleziona una foto del tuo pasto")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)
                    }

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Scegli dalla Libreria", systemImage: "photo.on.rectangle.angled")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                                analysis = nil
                                errorMessage = nil
                            }
                        }
                    }

                    if selectedImage != nil {
                        Button(action: analyzeImage) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 4)
                                    Text("Analisi in corso...")
                                } else {
                                    Image(systemName: "sparkles")
                                    Text("Calcola Calorie")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isAnalyzing ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .fontWeight(.semibold)
                        }
                        .disabled(isAnalyzing)
                        .padding(.horizontal)
                    }

                    if let error = errorMessage {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("MeowApp")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .navigationDestination(isPresented: $showingResult) {
                if let analysis = analysis {
                    ResultView(analysis: analysis)
                }
            }
            .sheet(isPresented: $showingSettings) {
                NavigationStack {
                    SettingsView()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Fine") { showingSettings = false }
                            }
                        }
                }
            }
        }
    }

    private func analyzeImage() {
        guard let image = selectedImage else { return }
        isAnalyzing = true
        errorMessage = nil

        Task {
            do {
                let result = try await claudeService.analyzeMeal(image: image)
                await MainActor.run {
                    analysis = result
                    isAnalyzing = false
                    showingResult = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isAnalyzing = false
                }
            }
        }
    }
}
