import Files

// Convenience `File` methods for the app.
extension File {
    private static let names = [
        "Arthur", "Anita", "Barbara", "Bernard", "Craig", "Chiara", "David",
        "Dean", "Éric", "Elena", "Fatima", "Frederik", "Gilbert", "Georgette",
        "Henriette", "Hassan", "Ignacio", "Irene", "Julie", "Jack", "Karl",
        "Kristel", "Louis", "Liz", "Masashi", "Mary", "Noam", "Nicole",
        "Ophelie", "Oleg", "Pascal", "Patricia", "Quentin", "Quinn", "Raoul",
        "Rachel", "Stephan", "Susie", "Tristan", "Tatiana", "Ursule", "Urbain",
        "Victor", "Violette", "Wilfried", "Wilhelmina", "Yvon", "Yann",
        "Zazie", "Zoé"]
    
    /// Creates a new file with random name and random score
    static func makeRandom(id: Int64? = nil) -> File {
        File(
            id: id,
            name: names.randomElement()!,
            folder: names.randomElement()!,
            contents: names.randomElement()!
        )
    }
    
    /// A placeholder File
    static let placeholder = File(name: "xxxxxx", folder: "", contents: "")
}
