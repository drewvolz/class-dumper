import SwiftUI

struct FilterScopeView: View {
    @AppStorage("scopedSearchPreference") var scopedSearchPreference = Preferences.Defaults.scopedSearch

    func getFilterText(_ filter: Preferences.FilterScope) -> String {
        switch filter {
            case .default: "Show selected"
            case .all: "Show all"
            default: "Unhandled filter"
        }
    }

    var body: some View {
        Picker("", selection: $scopedSearchPreference) {
            ForEach(Preferences.FilterScope.allCases) { filter in
                Text(getFilterText(filter)).tag(filter)
            }
        }
        .pickerStyle(.menu)
        .fixedSize()
    }
}

#Preview {
    FilterScopeView()
}
