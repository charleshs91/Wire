import Foundation

extension URL {
    static var demo: URL {
        return URL(string: "https://www.example.com/api/endpoint")!
    }
}

extension Data {
    static var demo: Data? {
        return "demo-data".data(using: .utf8)
    }
}

extension String {
    static var validURLString: String {
        return "https://www.example.com/api/endpoint"
    }

    static var invalidURLStrings: [String] {
        return [
            // whitespaces
            "https://www.example.com/api/endpoint ",
            // backslash
            "https://www.example.com\\api\\endpoint",
            // pound sign
            "http://##/",
        ]
    }
}
