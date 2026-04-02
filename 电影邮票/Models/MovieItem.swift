import SwiftUI
import SwiftData

@Model
final class MovieItem {
    var title: String
    var review: String
    var rating: Double
    var watchDate: Date
    var companions: String = "" // 和谁一起看
    @Attribute(.externalStorage) var posterImageData: Data? // 存储海报图片
    @Attribute(.externalStorage) var companionImageData: Data? // 存储合照图片
    
    // Position (For custom placement)
    // Default to the center of our 4000x4000 canvas
    var xPosition: Double = 2000.0
    var yPosition: Double = 2000.0
    
    // Scale (Manual adjustment)
    var scale: Double = 1.0
    var rotation: Double = 0.0
    
    init(title: String, review: String = "", rating: Double = 5.0, watchDate: Date = Date(), companions: String = "", posterImageData: Data? = nil, companionImageData: Data? = nil, x: Double = 2000.0, y: Double = 2000.0, scale: Double = 1.0, rotation: Double = 0.0) {
        self.title = title
        self.review = review
        self.rating = rating
        self.watchDate = watchDate
        self.companions = companions
        self.posterImageData = posterImageData
        self.companionImageData = companionImageData
        self.xPosition = x
        self.yPosition = y
        self.scale = scale
        self.rotation = rotation
    }
}
