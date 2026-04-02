import SwiftUI
import SwiftData

struct EditMovieView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var movie: MovieItem
    @ObservedObject var lang = LanguageManager.shared
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Movie Info") {
                    TextField("Title", text: $movie.title)
                    DatePicker("Watch Date", selection: $movie.watchDate, displayedComponents: .date)
                    Slider(value: $movie.rating, in: 1...5, step: 0.5) {
                        Text("Rating")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("5")
                    }
                }
                
                Section("Journal") {
                    TextEditor(text: $movie.review)
                        .frame(minHeight: 100)
                    TextField("Companions", text: $movie.companions)
                }
            }
            .navigationTitle("Edit Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
