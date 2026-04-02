import SwiftUI
import SwiftData

struct SearchArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    let movies: [MovieItem]
    
    @State private var searchText = ""
    @State private var expandedMonth: String? = nil
    @State private var selectedMovie: MovieItem? = nil
    @State private var carouselIndex: Int = 0 
    @State private var isGridView: Bool = false // Toggle between Carousel and Grid
    @ObservedObject var lang = LanguageManager.shared
    
    // Grouping Logic
    struct LocalMonthlyGroup: Identifiable {
        let id: Date
        let monthString: String
        let movies: [MovieItem]
    }
    
    var filteredMonthlyGroups: [LocalMonthlyGroup] {
        let filtered = movies.filter { 
            searchText.isEmpty || 
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.review.localizedCaseInsensitiveContains(searchText)
        }
        
        // Group by month
        let groups = Dictionary(grouping: filtered) { movie in
            Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: movie.watchDate)) ?? Date()
        }
        
        return groups.map { id, movies in
            LocalMonthlyGroup(id: id, monthString: formatDate(id), movies: movies.sorted(by: { $0.watchDate > $1.watchDate }))
        }
        .sorted { $0.id > $1.id }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Header
                VStack(spacing: 15) {
                    Text(lang.s("search_memories"))
                        .font(.custom("Palatino-Bold", size: 32))
                        .foregroundStyle(AppTheme.Colors.waxRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField(lang.s("search_memories"), text: $searchText)
                            .font(.system(.body, design: .serif))
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 70)
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
                .blur(radius: expandedMonth != nil ? 15 : 0)
                
                // MARK: - Grid of Envelopes
                ScrollView(showsIndicators: false) {
                    if filteredMonthlyGroups.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 20)], spacing: 30) {
                            ForEach(filteredMonthlyGroups) { group in
                                envelopeItem(group)
                            }
                        }
                        .padding(25)
                        .padding(.bottom, 150)
                    }
                }
                .blur(radius: expandedMonth != nil ? 15 : 0)
            }
            
            // MARK: - Modal Overlay (Carousel or Overview Grid)
            if let month = expandedMonth, let group = filteredMonthlyGroups.first(where: { $0.monthString == month }) {
                carouselOverlay(for: group)
            }
        }
        .fullScreenCover(item: $selectedMovie) { movie in
            MovieLetterView(movie: movie)
        }
    }
    
    // MARK: - Subviews
    
    private func envelopeItem(_ group: LocalMonthlyGroup) -> some View {
        EnvelopeView(
            month: group.monthString, 
            movieCount: group.movies.count, 
            isOpen: .constant(false)
        )
        .onTapGesture {
            openEnvelope(group.monthString)
        }
    }
    
    private func carouselOverlay(for group: LocalMonthlyGroup) -> some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { closeEnvelope() }
            
            VStack(spacing: 0) {
                // Header in Overlay
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.monthString)
                            .font(.custom("Palatino-Bold", size: 28))
                        Text("\(group.movies.count) Memories collected")
                            .font(.custom("Palatino-Italic", size: 14))
                            .opacity(0.8)
                    }
                    .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // MARK: - MODE TOGGLE BUTTON (Grid Overview)
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isGridView.toggle()
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Image(systemName: isGridView ? "doc.text.image.fill" : "square.grid.3x3.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    .padding(.trailing, 12)
                    
                    Button(action: { closeEnvelope() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                if isGridView {
                    // MARK: - GRID OVERVIEW (統揽模式)
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(Array(group.movies.enumerated()), id: \.element.id) { index, movie in
                                gridThumbnail(movie: movie)
                                    .onTapGesture {
                                        carouselIndex = index
                                        withAnimation { isGridView = false }
                                    }
                            }
                        }
                        .padding(25)
                        .padding(.bottom, 80)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    // MARK: - CAROUSEL MODE (大图轮播 + 呼吸式光影动态)
                    Spacer()
                    TabView(selection: $carouselIndex) {
                        ForEach(Array(group.movies.enumerated()), id: \.element.id) { index, movie in
                            BigMovieCard(movie: movie)
                                .padding(.horizontal, 10)
                                .frame(width: 320, height: 450) 
                                .tag(index)
                                // 动态光影核心：非当前选中的卡片自动变暗并轻微缩小，营造呼吸感
                                .opacity(carouselIndex == index ? 1.0 : 0.4)
                                .scaleEffect(carouselIndex == index ? 1.0 : 0.92)
                                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: carouselIndex)
                                .onTapGesture {
                                    selectedMovie = movie
                                }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 520)
                    
                    // 向上顶起，避开底部底座按键
                    Spacer(minLength: 120) 
                }
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
    }
    
    private func gridThumbnail(movie: MovieItem) -> some View {
        VStack(spacing: 8) {
            ZStack {
                if let data = movie.posterImageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.gray.opacity(0.1)
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
            
            Text(movie.title)
                .font(.system(size: 11, weight: .bold, design: .serif))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
        }
    }
    
    private func thumbnailItem(movie: MovieItem, isSelected: Bool) -> some View {
        ZStack {
            if let data = movie.posterImageData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(width: 45, height: 65)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? AppTheme.Colors.waxRed : Color.clear, lineWidth: 3)
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .shadow(radius: isSelected ? 5 : 0)
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 100)
            Image(systemName: "envelope.open.fill")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            Text(searchText.isEmpty ? "Start your collection" : "No match found")
                .font(.system(.body, design: .serif))
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Helpers
    
    private func openEnvelope(_ month: String) {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.75, blendDuration: 0)) {
            expandedMonth = month
            carouselIndex = 0
        }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    
    private func closeEnvelope() {
        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.85, blendDuration: 0)) {
            expandedMonth = nil
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = lang.selectedLanguage == .simplifiedChinese ? "yyyy.MM" : "MMM yyyy"
        f.locale = Locale(identifier: lang.selectedLanguage == .simplifiedChinese ? "zh_CN" : "en_US")
        return f.string(from: date)
    }
}

// MARK: - Enlarged Card for Carousel
struct BigMovieCard: View {
    let movie: MovieItem
    var body: some View {
        VStack(spacing: 0) {
            // Poster
            ZStack {
                if let data = movie.posterImageData, let uiImg = UIImage(data: data) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 260, height: 320)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 260, height: 320)
                        .overlay(Image(systemName: "film").font(.largeTitle))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(15)
            
            // Movie Title & Info
            VStack(spacing: 8) {
                Text(movie.title)
                    .font(.custom("Palatino-Bold", size: 22))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .lineLimit(1)
                
                RatingStars(rating: movie.rating)
                    .scaleEffect(0.9)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(movie.watchDate.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(AppTheme.Colors.waxRed.opacity(0.6))
            }
            .padding(.bottom, 20)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                VintagePaperTexture().opacity(0.06).clipShape(RoundedRectangle(cornerRadius: 20))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
    }
}


