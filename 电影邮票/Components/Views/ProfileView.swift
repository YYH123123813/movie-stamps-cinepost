import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MovieItem.watchDate, order: .reverse) private var movies: [MovieItem]
    @ObservedObject var lang = LanguageManager.shared
    
    @State private var showAboutSheet = false
    @State private var showShareSheet = false
    @State private var exportURL: URL?
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 70))
                        .foregroundStyle(AppTheme.Colors.waxRed)
                        .padding(.top, 40)
                    
                    Text("CinePost")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                    
                    Text("Digital Philately Collection")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 30)
                
                List {
                    // MARK: - PREFERENCES
                    Section(header: Text(lang.s("settings"))) {
                        Picker(selection: $lang.selectedLanguage) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.displayName).tag(language)
                            }
                        } label: {
                            Label(lang.s("language"), systemImage: "globe")
                        }
                    }
                    
                    // MARK: - DATA MANAGEMENT
                    Section(header: Text("Data")) {
                        // Export Button
                        Button {
                            exportData()
                        } label: {
                            Label(lang.s("export_data"), systemImage: "square.and.arrow.up")
                                .foregroundStyle(.primary)
                        }
                        
                        // Clear Data Button
                        Button(role: .destructive) {
                            clearAllData()
                        } label: {
                            Label("Clear All Data", systemImage: "trash")
                        }
                    }
                    
                    // MARK: - APP INFO
                    Section(header: Text("About")) {
                        Button {
                            showAboutSheet = true
                        } label: {
                            Label(lang.s("about"), systemImage: "info.circle")
                                .foregroundStyle(.primary)
                        }
                        
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden) 
            }
            .background(AppTheme.Colors.paperCanvas.ignoresSafeArea())
            .sheet(isPresented: $showAboutSheet) {
                AboutView()
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    // MARK: - Logic
    
    private func clearAllData() {
        withAnimation {
            for movie in movies {
                modelContext.delete(movie)
            }
        }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    private func exportData() {
        // Simple JSON Export logic
        let exportItems = movies.map { 
            MovieExportItem(
                title: $0.title,
                review: $0.review,
                rating: $0.rating,
                watchDate: $0.watchDate,
                companions: $0.companions
            )
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(exportItems)
            
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("CinePost_BackUp_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).json")
            
            try data.write(to: fileURL)
            self.exportURL = fileURL
            self.showShareSheet = true
            
        } catch {
            print("Failed to export: \(error.localizedDescription)")
        }
    }
}

// Helper Struct for JSON Export
struct MovieExportItem: Codable {
    let title: String
    let review: String
    let rating: Double
    let watchDate: Date
    let companions: String
}

// ShareSheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// About View
struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.Colors.paperCanvas.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "film.stack.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppTheme.Colors.waxRed)
                    .padding(.top, 40)
                
                Text("CinePost")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                
                Text("Designed for Film Lovers")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                Divider()
                    .padding(.horizontal, 40)
                
                Text("CinePost brings the nostalgia of philately to your digital movie journal. Every film you watch becomes a stamp in your collection.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.Colors.waxRed)
                .padding(.bottom, 30)
            }
        }
    }
}
