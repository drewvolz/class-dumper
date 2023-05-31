import Foundation

extension String {
    func forSearch() -> String {
        folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
    
    func removeSpaces() -> String {
        replacingOccurrences(of: " ", with: "")
    }
}
