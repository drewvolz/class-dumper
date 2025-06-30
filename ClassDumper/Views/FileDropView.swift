import SwiftUI
import UniformTypeIdentifiers

struct FileDropView: View {
    @Environment(\.fileRepository) private var fileRepository
    @EnvironmentObject var alertController: AlertController
    @AppStorage("accent") var accent = CodableColor(.accentColor)
    @AppStorage("confirmBeforeImport") var confirmBeforeImport: Bool = true

    @State private var isTargeted = false
    @State private var selectedFile: DroppedFile?

    var body: some View {
        ZStack {
            Color.clear

            if isTargeted {
                VStack {
                    Spacer()

                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accent.toColor(), style: StrokeStyle(lineWidth: 3, dash: [10]))
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(accent.toColor().opacity(0.1))
                        )
                        .frame(width: 450, height: 450)
                        .overlay(
                            VStack(spacing: 16) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(accent.toColor())

                                Text("Drop file to process")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(accent.toColor())
                            }
                        )

                    Spacer()
                }
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
        .sheet(item: $selectedFile) { dropped in
            FileProcessingModal(
                fileURL: dropped.url,
                onDismiss: { selectedFile = nil }
            )
            .environment(\.fileRepository, fileRepository)
            .environmentObject(alertController)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        guard let provider = providers.first else { return }
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            DispatchQueue.main.async {
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil)
                {
                    if confirmBeforeImport {
                        let newFile = DroppedFile(url: url)
                        if selectedFile != nil {
                            selectedFile = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                selectedFile = newFile
                            }
                        } else {
                            selectedFile = newFile
                        }
                    } else {
                        processFileDirectly(url: url)
                    }
                }
            }
        }
    }

    private func processFileDirectly(url: URL) {
        let _ = FileProcessingUtils.processFile(fileURL: url, alertController: alertController)
        NotificationCenter.default.post(name: .folderSelectedFromFinderNotification, object: nil)
        FileProcessingUtils.deleteTempDirectory()
    }
}

struct DroppedFile: Identifiable, Equatable {
    let url: URL
    var id: String { url.path }
}

struct FileProcessingModal: View {
    let fileURL: URL
    var onDismiss: () -> Void
    @Environment(\.fileRepository) private var fileRepository
    @EnvironmentObject var alertController: AlertController
    @AppStorage("accent") var accent = CodableColor(.accentColor)

    @State private var isProcessing = false
    @State private var fileInfo: FileInfo?
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 4) {
            Spacer()
            if let fileInfo = fileInfo {
                Image(nsImage: NSWorkspace.shared.icon(forFile: fileInfo.path))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .padding(.top, 12)

                Text(fileInfo.name)
                    .padding(.horizontal, 30)
                    .lineLimit(2)
                    .font(.title3).bold()
                    .multilineTextAlignment(.center)

                Text(fileInfo.type)
                    .padding(.horizontal, 30)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .foregroundColor(.secondary)
            } else {
                ProgressView()
                    .padding(.vertical, 20)
            }
            Spacer()

            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 0) {
                    Button(role: .cancel, action: { onDismiss() }) {
                        Text("Cancel")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 30)
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    .keyboardShortcut(.escape)

                    Button(action: processFile) {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.5)
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.horizontal, 30)
                        } else {
                            Text("Import")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 30)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing || fileInfo == nil || isLoading)
                    .keyboardShortcut(.return)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
        }
        .frame(width: 300, height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onAppear { loadFileInfo() }
        .onDisappear {
            isProcessing = false
            isLoading = true
            fileInfo = nil
        }
    }

    private func loadFileInfo() {
        isLoading = true
        Task {
            let info = await getFileInfo(for: fileURL)
            await MainActor.run {
                self.fileInfo = info
                self.isLoading = false
            }
        }
    }

    private func getFileInfo(for url: URL) async -> FileInfo {
        let fileManager = FileManager.default
        let attributes = try? fileManager.attributesOfItem(atPath: url.path)
        let creationDate = attributes?[.creationDate] as? Date
        let modificationDate = attributes?[.modificationDate] as? Date
        let fileType = getFileType(for: url)
        return FileInfo(
            name: url.lastPathComponent,
            path: url.path,
            type: fileType,
            creationDate: creationDate,
            modificationDate: modificationDate
        )
    }

    private func getFileType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "app": return "App Bundle"
        case "appex": return "Application and System Extension"
        case "dylib": return "Dynamic Library"
        case "framework": return "Framework"
        case "xcplugindata": return "Xcode Compiled Plug-in Data"
        case "": return "Executable"
        default: return pathExtension
        }
    }

    private func processFile() {
        isProcessing = true
        Task {
            await MainActor.run {
                let result = FileProcessingUtils.processFile(fileURL: fileURL, alertController: alertController)
                switch result {
                case .success:
                    NotificationCenter.default.post(name: .folderSelectedFromFinderNotification, object: nil)
                    FileProcessingUtils.deleteTempDirectory()
                case .failure:
                    FileProcessingUtils.deleteTempDirectory()
                }
                isProcessing = false
                onDismiss()
            }
        }
    }
}

struct FileInfo {
    let name: String
    let path: String
    let type: String
    let creationDate: Date?
    let modificationDate: Date?
}

#Preview("Short path") {
    FileProcessingModal(
        fileURL: URL(fileURLWithPath: "/System/Applications/Calculator.app"),
        onDismiss: {}
    )
    .environmentObject(AlertController())
}

#Preview("Long path") {
    FileProcessingModal(
        fileURL: URL(fileURLWithPath: "/Applications/Swift Playground.app/Contents/macOSFrameworks/AssetCatalogFoundation.framework/Versions/A/Resources/AssetCatalogFoundation.xcplugindata"),
        onDismiss: {}
    )
    .environmentObject(AlertController())
}
