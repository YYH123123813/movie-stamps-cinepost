import SwiftUI
import SwiftData
import PhotosUI

struct AddMovieView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allMovies: [MovieItem] 
    @ObservedObject var lang = LanguageManager.shared
    
    // Core Data
    @State private var title: String = ""
    @State private var companions: String = ""
    @State private var review: String = ""
    @State private var rating: Double = 5.0
    @State private var watchDate: Date = Date()
    
    // Images
    @State private var selectedPosterItem: PhotosPickerItem?
    @State private var selectedPosterImage: Image?
    @State private var posterData: Data?
    
    @State private var selectedCompanionItem: PhotosPickerItem?
    @State private var selectedCompanionImage: Image?
    @State private var companionData: Data?
    
    var body: some View {
        ZStack {
            // MARK: - BACKGROUND
            AppTheme.Colors.paperCanvas.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - HEADER (Screenshot Matched)
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CinePost")
                            .font(.system(size: 36, weight: .black, design: .serif))
                            .foregroundStyle(.black.opacity(0.85))
                    }
                    Spacer()
                    Button(action: { saveMovie() }) {
                        Text(lang.s("seal_it"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.waxRed.opacity(0.8))
                            .padding(.horizontal, 22)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
                            )
                    }
                    .disabled(title.isEmpty)
                }
                .padding(.horizontal, 25)
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // MARK: - 1. VISUAL MEMORY (Two Image Slots)
                        VStack(alignment: .leading, spacing: 12) {
                            Text(lang.s("visual_memory"))
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.secondary)
                                .padding(.leading, 5)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    // Slot 1: Poster
                                    ImageSlot(
                                        title: lang.s("movie_poster"),
                                        image: selectedPosterImage,
                                        icon: "film",
                                        color: .blue
                                    ) {
                                        PhotosPicker(selection: $selectedPosterItem, matching: .images) {
                                            Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                    }
                                    
                                    // Slot 2: Record Photo (时光合影)
                                    ImageSlot(
                                        title: lang.s("time_together"),
                                        image: selectedCompanionImage,
                                        icon: "camera.shutter.button",
                                        color: .pink
                                    ) {
                                        PhotosPicker(selection: $selectedCompanionItem, matching: .images) {
                                            Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                    }
                                }
                                .padding(.horizontal, 5)
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        // MARK: - 2. BASIC INFO
                        VStack(spacing: 20) {
                            // Title Input
                            InputCard(label: lang.s("movie_title"), placeholder: lang.s("placeholder_title"), text: $title)
                            
                            // Companion Input
                            InputCard(label: lang.s("with_whom"), placeholder: lang.s("placeholder_with"), text: $companions)
                        }
                        .padding(.horizontal, 25)
                        
                        // MARK: - 3. RATING & THOUGHTS
                        VStack(alignment: .leading, spacing: 15) {
                            Text(lang.s("rating"))
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.secondary)
                                .padding(.leading, 30)
                            
                            VStack(spacing: 20) {
                                // Star Rating Input
                                RatingInputView(rating: $rating)
                                
                                Divider().background(Color.black.opacity(0.05))
                                
                                // Thoughts TextEditor
                                TextEditor(text: $review)
                                    .frame(minHeight: 120)
                                    .font(.system(.body, design: .serif))
                                    .scrollContentBackground(.hidden)
                                    .overlay(
                                        VStack {
                                            if review.isEmpty {
                                                Text(lang.s("placeholder_thoughts"))
                                                    .foregroundStyle(.placeholder)
                                                    .padding(.top, 8)
                                                    .padding(.leading, 5)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            Spacer()
                                        }
                                    )
                            }
                            .padding(20)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color.white))
                            .padding(.horizontal, 25)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        // Change Handlers
        .onChange(of: selectedPosterItem) { _, i in 
            Task { 
                if let d = try? await i?.loadTransferable(type: Data.self), let ui = UIImage(data: d) { 
                    posterData = d; selectedPosterImage = Image(uiImage: ui) 
                } 
            } 
        }
        .onChange(of: selectedCompanionItem) { _, i in 
            Task { 
                if let d = try? await i?.loadTransferable(type: Data.self), let ui = UIImage(data: d) { 
                    companionData = d; selectedCompanionImage = Image(uiImage: ui) 
                } 
            } 
        }
    }
    
    private func saveMovie() {
        // Haptic Feedback for confirmation
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        let index = allMovies.count
        
        // 优化布局逻辑：错落式排列，防止完美重叠
        // 以 (2000, 2000) 为原始中心，根据索引进行行列偏移
        let column = index % 3 // 3列分布
        let row = index / 3
        
        // 基础位置 + 偏移 + 随机扰动（增加真实感）
        let baseOffsetX = Double(column - 1) * 220.0 
        let baseOffsetY = Double(row) * 280.0
        let randomNoiseX = Double.random(in: -20...20)
        let randomNoiseY = Double.random(in: -20...20)
        
        let targetX = 2000.0 + baseOffsetX + randomNoiseX
        let targetY = 2000.0 + baseOffsetY + randomNoiseY
        
        let newMovie = MovieItem(
            title: title.isEmpty ? "Untitled" : title, 
            review: review, 
            rating: rating, 
            watchDate: watchDate, 
            companions: companions, 
            posterImageData: posterData, 
            companionImageData: companionData,
            x: targetX, 
            y: targetY
        )
        
        modelContext.insert(newMovie)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save movie: \(error)")
            // Still dismiss if save fails to avoid blocking the user, 
            // but in a real app we might show an error.
            dismiss()
        }
    }
}

// MARK: - HELPER SUBVIEWS (Restored and Polished)

struct ImageSlot<Content: View>: View {
    let title: String
    let image: Image?
    let icon: String
    let color: Color
    @ViewBuilder var picker: () -> Content
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                
                if let image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: icon)
                            .font(.system(size: 28))
                            .foregroundStyle(color.opacity(0.6))
                        Text(title)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 140, height: 180)
            .overlay(picker())
        }
    }
}

struct InputCard: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(.secondary)
                .padding(.leading, 5)
            
            TextField(placeholder, text: $text)
                .font(.system(.body, design: .serif))
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        }
    }
}

struct RatingInputView: View {
    @Binding var rating: Double
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= Int(rating) ? "star.fill" : "star")
                    .font(.system(size: 28))
                    .foregroundStyle(i <= Int(rating) ? .orange : .gray.opacity(0.3))
                    .onTapGesture {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        rating = Double(i)
                    }
            }
            Spacer()
            Text(String(format: "%.1f", rating))
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.Colors.waxRed)
        }
    }
}
