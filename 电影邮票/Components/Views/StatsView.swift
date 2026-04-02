import SwiftUI

struct StatsView: View {
    let movies: [MovieItem]
    @ObservedObject var lang = LanguageManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Header
                HStack {
                    Text(lang.s("stats_title"))
                        .font(.system(size: 32, weight: .black, design: .serif))
                        .foregroundStyle(Color.primary)
                    Spacer()
                }
                .padding(.top, 80)
                .padding(.horizontal, 25)
                
                // Key Metrics
                HStack(spacing: 20) {
                    StatBox(
                        title: lang.s("collected"),
                        value: "\(movies.count)",
                        icon: "ticket.fill"
                    )
                    
                    let avg = movies.isEmpty ? 0.0 : movies.reduce(0){$0+$1.rating}/Double(movies.count)
                    StatBox(
                        title: lang.s("average_rating"),
                        value: String(format: "%.1f", avg),
                        icon: "star.fill",
                        valueColor: .orange
                    )
                }
                .padding(.horizontal, 25)
                
                // Additional Stats (Placeholder for future optimization)
                if !movies.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Top Genre")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 25)
                        
                        // A simple visualization placeholder
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppTheme.Colors.classicBlue.opacity(0.3))
                                .frame(height: 40)
                                .overlay(Text("Drama (40%)").font(.caption).bold())
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppTheme.Colors.waxRed.opacity(0.3))
                                .frame(height: 40)
                                .overlay(Text("Sci-Fi (60%)").font(.caption).bold())
                        }
                        .padding(.horizontal, 25)
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .background(Color.clear) // Ensure it layers correctly over global background
    }
}

struct StatBox: View {
    let title: String
    let value: String
    var icon: String? = nil
    var valueColor: Color = AppTheme.Colors.waxRed
    
    var body: some View {
        VStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(valueColor.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Text(value)
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(valueColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(title)
                .font(.system(.caption, design: .serif).bold())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.7))
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 1)
        )
    }
}
