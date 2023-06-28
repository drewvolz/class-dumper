import Foundation

extension String {
    func forSearch() -> String {
        folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
    
    func removeSpaces() -> String {
        replacingOccurrences(of: " ", with: "")
    }

    func truncate(length: Int, trailing: String = "…") -> String {
        let maxLength = length - trailing.count
        guard maxLength > 0, !self.isEmpty, self.count > length else {
            return self
        }
        return self.prefix(maxLength) + trailing
    }
}
