import Combine
import GRDB
import GRDBQuery
import Files
import SwiftUI

/// The sheet for file edition.
///
/// In this demo app, this view don't want to remain on screen
/// whenever the edited file no longer exists in the database.
struct FileEditionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query<FilePresenceRequest>
    private var filePresence: FilePresence
    
    @State var goneFileAlertPresented = false
    
    init(id: Int64) {
        _filePresence = Query(FilePresenceRequest(id: id))
    }
    
    var body: some View {
        NavigationView {
            if let file = filePresence.file {
                VStack {
                    FileFormView(file: file)
                    
                    Spacer()
                    
                    if filePresence.exists {
                        VStack(spacing: 10) {
                            Text("What if another application component deletes the file at the most unexpected moment?")
                                .informationStyle()
                            DeleteFilesButton("Delete File")
                        }
                        .informationBox()
                    }
                }
                .padding(.horizontal)
                .navigationTitle(file.name)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button("Done") { dismiss() }
                    }
                }
            } else {
                FileNotFoundView()
            }
        }
        .alert("Ooops, file is gone.", isPresented: $goneFileAlertPresented, actions: {
            Button("Dismiss") { dismiss() }
        })
        .onAppear {
            if !filePresence.exists {
                goneFileAlertPresented = true
            }
        }
        .onChange(of: filePresence.exists, perform: { fileExists in
            if !fileExists {
                goneFileAlertPresented = true
            }
        })
    }
}

/// A @Query request that observes the presence of the file in the database.
private struct FilePresenceRequest: Queryable {
    static var defaultValue: FilePresence { .missing }
    
    var id: Int64
    
    func publisher(in fileRepository: FileRepository) -> AnyPublisher<FilePresence, Error> {
        ValueObservation
            .tracking(File.filter(key: id).fetchOne)
            .publisher(in: fileRepository.reader, scheduling: .immediate)
            // Use scan in order to detect the three cases of file presence
            .scan(.missing) { (previous, file) in
                if let file {
                    return .existing(file)
                } else if let file = previous.file {
                    return .gone(file)
                } else {
                    return .missing
                }
            }
            .eraseToAnyPublisher()
    }
}

// We handle three distinct cases regarding the presence of the
// edited file:
private enum FilePresence {
    /// The file exists in the database
    case existing(File)
    
    /// File no longer exists, but we have its latest value.
    case gone(File)
    
    /// File does not exist, and we don't have any information about it.
    case missing
    
    var file: File? {
        switch self {
        case let .existing(file), let .gone(file):
            return file
        case .missing:
            return nil
        }
    }
    
    var exists: Bool {
        switch self {
        case .existing:
            return true
        case .gone, .missing:
            return false
        }
    }
}

struct FileEditionView_Previews: PreviewProvider {
    static var previews: some View {
        FileEditionView(id: 1)
            .environment(\.fileRepository, .populated(fileId: 1))
            .previewDisplayName("Existing file")
        
        FileEditionView(id: -1)
            .environment(\.fileRepository, .empty())
            .previewDisplayName("Missing file")
    }
}
