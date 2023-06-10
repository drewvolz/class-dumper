import Foundation

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]
}

extension Endpoint {
    enum IssueType {
        case Bug
        case Feature
    }
    
    static let githubBaseUrl = "https://github.com/drewvolz/class-dumper"

    static func issue(_ type: IssueType) -> Endpoint {
        var label: String
        var template: String

        switch type {
        case .Feature:
            label = "enhancement"
            template = "feature_request.md"
        case .Bug:
            label = "bug"
            template = "bug_report.md"
        }

        return Endpoint(
            path: "/drewvolz/class-dumper/issues/new",
            queryItems: [
                .init(name: "assignees", value: ""),
                .init(name: "label", value: label),
                .init(name: "template", value: template),
                .init(name: "title", value: "")
            ]
        )
    }

    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}
