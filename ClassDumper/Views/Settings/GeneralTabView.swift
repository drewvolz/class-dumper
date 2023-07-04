import SwiftUI

struct GeneralSettingsView: View {
    var body: some View {
        Group {
            DeleteFilesButton("Delete all saved data", afterWithPrompt: {
                // noop, deletion with prompting is handled in the button
                // but side effects may be placed here if desired.
            })
        }
        .modifier(PreferencesTabViewModifier(sectionTitle: "Database"))
    }
}
