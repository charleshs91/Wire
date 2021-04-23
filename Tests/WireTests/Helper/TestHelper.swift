import Foundation

extension URLSession {
    static var testing: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [TestURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

extension URL {
    static var demo: URL {
        return URL(string: "https://www.example.com/api/endpoint")!
    }

    static var success: URL {
        return URL(string: "https://www.example.com/api/success")!
    }

    static var noResponse: URL {
        return URL(string: "https://www.example.com/api/noResponse")!
    }

    static var notHTTP: URL {
        return URL(string: "https://www.example.com/api/notHTTP")!
    }

    static var noData: URL {
        return URL(string: "https://www.example.com/api/noData")!
    }

    static func statusCode(_ code: Int) -> URL {
        return URL(string: "https://www.example.com/api/status/\(code)")!
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

extension Result {
    var error: Error? {
        switch self {
        case .failure(let error): return error
        default: return nil
        }
    }
}

enum TestError: Error {
    case failure
}

struct TestCodableObj: Codable {
    static var success: TestCodableObj = TestCodableObj(description: "Success")

    let description: String
}
