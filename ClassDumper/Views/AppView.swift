import GRDB
import GRDBQuery
import Files
import SwiftUI

/// The main application view
struct AppView: View {
    /// A helper `Identifiable` type that can feed SwiftUI `sheet(item:onDismiss:content:)`
    private struct EditedFile: Identifiable {
        var id: Int64
    }
    
    @Query(FileRequest())
    private var file: File?
    
    @State private var editedFile: EditedFile?
    
    var body: some View {
        NavigationSplitView {
            if let file, let id = file.id {
                FileView(file: file, editAction: { editFile(id: id) })
                    .padding(.vertical)
                    .padding(.horizontal)

                Spacer()
                populatedFooter(id: id)
            } else {
                FileView(file: .placeholder)
                    .padding(.vertical)
                    .redacted(reason: .placeholder)
                    .padding(.horizontal)

                Spacer()
                emptyFooter()
            }
        } content: {

        } detail: {
            Text("")
        }
        .padding(.horizontal)
        .sheet(item: $editedFile) { file in
            FileEditionView(id: file.id)
        }
        .navigationTitle(NSApplication.bundleName)
    }
}

extension AppView {
    private func emptyFooter() -> some View {
        VStack {
            Text("The demo application observes the database and displays information about the file.")
                .informationStyle()
            
            CreateFileButton("Create a File")
        }
        .informationBox()
    }
    
    private func populatedFooter(id: Int64) -> some View {
        VStack(spacing: 10) {
            Text("What if another application component deletes the file at the most unexpected moment?")
                .informationStyle()
            DeleteFilesButton("Delete File")
            
            Spacer().frame(height: 10)
            Text("What if the file is deleted soon after the Edit button is hit?")
                .informationStyle()
            DeleteFilesButton("Delete After Editing", after: {
                editFile(id: id)
            })
            
            Spacer().frame(height: 10)
            Text("What if the file is deleted right before the Edit button is hit?")
                .informationStyle()
            DeleteFilesButton("Delete Before Editing", before: {
                editFile(id: id)
            })
        }
        .informationBox()
    }
    
    private func editFile(id: Int64) {
        editedFile = EditedFile(id: id)
    }
}

/// A @Query request that observes the file (any file, actually) in the database
private struct FileRequest: Queryable {
    static var defaultValue: File? { nil }
    
    func publisher(in fileRepository: FileRepository) -> DatabasePublishers.Value<File?> {
        ValueObservation
            .tracking(File.fetchOne)
            .publisher(in: fileRepository.reader, scheduling: .immediate)
    }
}
