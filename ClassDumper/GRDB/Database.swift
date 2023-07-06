import Files

// Convenience `File` methods for the app.
extension File {
    /// Creates a new file with random name and random score
    static func makeRandom(id: Int64? = nil) -> File {
        File(
            id: id,
            name: "B",
            folder: "A",
            contents: "C"
        )
    }
    
    static func createFile(id: Int64? = nil, name: String, folder: String, contents: String) -> File {
        File(id: id, name: name, folder: folder, contents: contents)
    }
    
    /// A placeholder File
    static let placeholder = File(name: "xxxxxx", folder: "", contents: "")
}
