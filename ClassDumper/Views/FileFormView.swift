import GRDB
import Files
import SwiftUI

/// The view that edits a file
struct FileFormView: View {
    @Environment(\.fileRepository) private var fileRepository
    let file: File
    
    var body: some View {
        Stepper(
            "Name: \(file.name)",
            onIncrement: { updateScore { $0 += "10" } }, // TODO: fixme
            onDecrement: { updateScore { $0 = "max(0, $0 - 10)" } }) // TODO: fixme
    }
    
    private func updateScore(_ transform: (inout String) -> Void) {
        do {
            var updatedFile = file
            transform(&updatedFile.name)
            try fileRepository.update(updatedFile)
        } catch RecordError.recordNotFound {
            // Oops, file does not exist.
            // Ignore this error: `FileEditionView` will dismiss.
        } catch {
            // Ignore other errors.
        }
    }
}

struct FileFormView_Previews: PreviewProvider {
    static var previews: some View {
        FileFormView(file: .makeRandom())
            .padding()
    }
}
