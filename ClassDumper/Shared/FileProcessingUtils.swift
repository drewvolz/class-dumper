import Foundation
import SwiftUI

enum FileProcessingResult {
    case success(URL)
    case failure(String)
}

enum FileProcessingUtils {
    /// Executes a command with the given executable URL and arguments
    /// - Parameters:
    ///   - executableURL: The URL of the executable to run
    ///   - args: The arguments to pass to the executable
    /// - Returns: The standard error output from the command
    static func executeCommand(executableURL: URL, args: [String]) -> String {
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        let task = Process()
        task.executableURL = executableURL
        task.arguments = args
        task.standardOutput = outputPipe
        task.standardError = errorPipe

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            fatalError("Something went wrong when trying to invoke \(executableURL.path)")
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let _ = String(decoding: outputData, as: UTF8.self)
        let standardError = String(decoding: errorData, as: UTF8.self)

        return standardError
    }

    /// Checks error output from file processing and displays appropriate alerts
    /// - Parameters:
    ///   - message: The error message to check
    ///   - outputDirectory: The output directory for context
    ///   - alertController: The alert controller to display messages
    /// - Returns: True if there was an error, false if successful
    static func checkErrorOutput(message: String, outputDirectory: URL, alertController: AlertController) -> Bool {
        @AppStorage("enableVerboseImportErrorLogging") var enableVerboseImportErrorLogging = Preferences.Defaults.verboseErrors
        @AppStorage("dialogLengthImportErrorLogging") var dialogLengthImportErrorLogging = Preferences.Defaults.dialogLength

        if !message.isEmpty {
            var messageTitle = ""
            var messageContent = ""

            // the most common error we'll come across is when no Mach-O files are generated
            let noRuntimeInfoWarning = "does not contain any Objective-C runtime information"

            switch message {
            case _ where message.contains(noRuntimeInfoWarning):
                messageTitle = "Nothing to parse"
                messageContent = "\(outputDirectory.lastPathComponent) \(noRuntimeInfoWarning)"
            default:
                messageTitle = "An unexpected error occurred"
                messageContent = message.formatConsoleOutput(
                    length: dialogLengthImportErrorLogging,
                    skip: enableVerboseImportErrorLogging
                )
            }

            alertController.info = AlertInfo(
                id: .importNoObjcRuntimeInformation,
                title: messageTitle,
                message: messageContent,
                level: .message
            )

            return true
        }

        return false
    }

    /// Processes a file using class-dump and handles the output
    /// - Parameters:
    ///   - fileURL: The URL of the file to process
    ///   - alertController: The alert controller for displaying messages
    /// - Returns: The result of the processing operation
    static func processFile(fileURL: URL, alertController: AlertController) -> FileProcessingResult {
        let outputDirectoryURL = outputDirectory
            .appendingPathComponent(fileURL.deletingPathExtension().lastPathComponent)

        try? FileManager.default.createDirectory(atPath: outputDirectoryURL.path, withIntermediateDirectories: true)

        if let path = Bundle.main.url(forResource: "class-dump", withExtension: "") {
            let errorOutput = executeCommand(executableURL: path, args: [fileURL.resolvingSymlinksInPath().path, "-t", "-H", "-o", outputDirectoryURL.path])
            let hasError = checkErrorOutput(message: errorOutput, outputDirectory: outputDirectoryURL, alertController: alertController)

            if hasError {
                return .failure(errorOutput)
            } else {
                return .success(outputDirectoryURL)
            }
        }

        return .failure("Could not find class-dump executable")
    }

    static func deleteTempDirectory() {
        try? FileManager.default.removeItem(atPath: outputDirectory.path)
    }
}
