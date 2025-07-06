import Foundation

extension String {
    /// Matches input against a regular expression capture group. Found matches are removed.
    private func clean(_ input: String, matching pattern: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: input.utf16.count)
            return regex.stringByReplacingMatches(in: input, range: range, withTemplate: "")
        } catch {
            print("Unexpected errors occurred while trying to clean up the log")
            return input
        }
    }

    /// Formats a log `message` to be a little more human readable
    ///
    /// Usage
    /// ```
    /// formatConsoleOutput(message)
    /// formatConsoleOutput(message, length: 2000)
    /// formatConsoleOutput(message, skip: true)
    /// ```
    ///
    /// Output
    /// ```
    /// # Before
    /// 2023-07-01 23:41:02.170 class-dump[26337:610266] Unknown load command: 0x00000032
    ///
    /// # After
    /// Unknown load command: 0x00000032
    /// ```
    ///
    /// > Warning: This step can be skipped for verbosity. Pass in
    /// > `skip: true` if the original message is needed. Beware
    /// > that skipping this step could present a dialog that extends
    /// > beyond the screen height as it will also skip truncation.
    ///
    /// - Parameters:
    ///     - length: The character length of the content (bypassed with skip).
    ///     - skip: Returns the original log (defaults to false).
    ///
    /// - Returns: A message with datetimes and program prefixes removed.
    func formatConsoleOutput(length: Int, skip: Bool) -> String {
        guard !skip else { return self }

        let datePattern = #"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}"#
        let prefixPattern = #"class-dump\[\d+:\d+\]"#

        let pattern = [datePattern, prefixPattern].map { "(\($0))" }.joined(separator: "|")
        let cleaned = clean(self, matching: pattern)

        return cleaned.truncate(length: length)
    }
}
