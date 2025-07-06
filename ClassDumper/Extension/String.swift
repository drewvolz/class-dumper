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
        guard maxLength > 0, !isEmpty, count > length else {
            return self
        }
        return prefix(maxLength) + trailing
    }
}
