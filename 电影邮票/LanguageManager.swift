import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case simplifiedChinese = "zh-Hans"
    case english = "en"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .simplifiedChinese: return "简体中文"
        case .english: return "English"
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var selectedLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        }
    }
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: "selectedLanguage") ?? AppLanguage.simplifiedChinese.rawValue
        self.selectedLanguage = AppLanguage(rawValue: saved) ?? .simplifiedChinese
    }
    
    func s(_ key: String) -> String {
        let localizedStrings: [AppLanguage: [String: String]] = [
            .simplifiedChinese: [
                "app_name": "CinePost",
                "visual_memory": "视觉记忆",
                "movie_poster": "电影海报",
                "time_together": "时光合影",
                "add_poster": "添加海报",
                "add_companion": "添加合影",
                "basic_info": "基本信息",
                "movie_title": "电影名称",
                "with_whom": "同行者",
                "watch_date": "观影日期",
                "thoughts": "观影感受",
                "rating": "评分",
                "seal_it": "存入信箱",
                "cancel": "取消",
                "no_journal": "暂无评论...",
                "search_memories": "记忆检索",
                "stats_title": "光影概览",
                "collected": "累计集邮",
                "average_rating": "平均评分",
                "settings": "系统设置",
                "export_data": "数据导出",
                "about": "关于 CinePost",
                "delete_stamp": "删除邮票",
                "placeholder_title": "例如: 星际穿越",
                "placeholder_with": "例如: 亲爱的他/她",
                "placeholder_thoughts": "写下那一刻的想法...",
                "language": "语言设置"
            ],
            .english: [
                "app_name": "CinePost",
                "visual_memory": "VISUAL MEMORY",
                "movie_poster": "MOVIE POSTER",
                "time_together": "TIME TOGETHER",
                "add_poster": "Add Poster",
                "add_companion": "Add Photo",
                "basic_info": "BASIC DETAILS",
                "movie_title": "MOVIE TITLE",
                "with_whom": "WITH WHOM",
                "watch_date": "WATCH DATE",
                "thoughts": "THOUGHTS",
                "rating": "RATE",
                "seal_it": "Seal It",
                "cancel": "Cancel",
                "no_journal": "No journal entry...",
                "search_memories": "Search Memories",
                "stats_title": "CinePost Archives",
                "collected": "Collected",
                "average_rating": "Average Rate",
                "settings": "Settings",
                "export_data": "Export Data",
                "about": "About CinePost",
                "delete_stamp": "Delete Photo",
                "placeholder_title": "e.g. Interstellar",
                "placeholder_with": "e.g. Alice",
                "placeholder_thoughts": "Write your thoughts...",
                "language": "Languages"
            ]
        ]
        
        return localizedStrings[selectedLanguage]?[key] ?? key
    }
}
