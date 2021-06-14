import Foundation

/// Represents a HTTP header field.
public enum HTTPHeader {
    case accept(ContentType)
    case acceptCharset(String)
    case acceptEncoding(String)
    case acceptLanguage(String)
    case acceptDateTime(String)
    case authorization(Authorization)
    case cacheControl(String)
    case connection(String)
    case cookie(String)
    case contentType(ContentType)
    case contentMD5(String)
    case date(String)
    case expect(String)
    case from(String)
    case ifMatch(String)
    case keepAlive(String)
    case referer(String)
    case userAgent(String)
    case other(key: String, value: String)

    /// The key of the header field.
    public var key: String {
        switch self {
        case .accept: return "Accept"
        case .acceptCharset: return "Accept-Charset"
        case .acceptEncoding: return "Accept-Encoding"
        case .acceptLanguage: return "Accept-Language"
        case .acceptDateTime: return "Accept-Datetime"
        case .authorization: return "Authorization"
        case .cacheControl: return "Cache-Control"
        case .connection: return "Connection"
        case .cookie: return "Cookie"
        case .contentType: return "Content-Type"
        case .contentMD5: return "Content-MD5"
        case .date: return "Date"
        case .expect: return "Expect"
        case .from: return "From"
        case .ifMatch: return "If-Match"
        case .keepAlive: return "Keep-Alive"
        case .referer: return "Referer"
        case .userAgent: return "User-Agent"
        case .other(let key, _): return key
        }
    }

    /// The value of the header field.
    public var value: String {
        switch self {
        case .authorization(let authroization):
            return authroization.value
        case .accept(let contentType),
             .contentType(let contentType):
            return contentType.value
        case .acceptCharset(let value),
             .acceptEncoding(let value),
             .acceptLanguage(let value),
             .acceptDateTime(let value),
             .cacheControl(let value),
             .connection(let value),
             .cookie(let value),
             .contentMD5(let value),
             .date(let value),
             .expect(let value),
             .from(let value),
             .ifMatch(let value),
             .keepAlive(let value),
             .referer(let value),
             .other(_, let value),
             .userAgent(let value):
            return value
        }
    }

    /// Modifies a URLRequest to apply this header.
    /// - Parameters:
    ///   - request: The request to apply headers to
    ///   - mergesField: Determines if the content gets merged to the same field. It defaults to `true`.
    func modify(request: inout URLRequest, mergesField: Bool = true) {
        if mergesField {
            request.addValue(value, forHTTPHeaderField: key)
        } else {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}

extension HTTPHeader: RequestModifiable {
    public func modify(_ request: URLRequest) -> Result<URLRequest, Error> {
        var req = request
        modify(request: &req)
        return .success(req)
    }
}

// MARK: - Authorization
extension HTTPHeader {
    /// Represents content of the `Authorization` HTTP header field.
    public enum Authorization {
        case basic(_ token: String)
        case bearer(_ token: String)
        case digest(_ token: String)
        case HOBA(_ token: String)
        case mutual(_ token: String)
        case other(String)

        /// The value for the `Authorization` field in a header.
        public var value: String {
            switch self {
            case .basic(let token):
                return "Basic \(token)"
            case .bearer(let token):
                return "Bearer \(token)"
            case .digest(let token):
                return "Digest \(token)"
            case .HOBA(let token):
                return "HOBA \(token)"
            case .mutual(let token):
                return "Mutual \(token)"
            case .other(let value):
                return value
            }
        }
    }
}

// MARK: - Content-Type
extension HTTPHeader {
    /// Represents content of the `Content-Type` HTTP header field.
    public enum ContentType {
        case formData
        case urlEncodedForm
        case json
        case plain
        case other(String)

        /// The value for the `Content-Type` field in a header.
        public var value: String {
            switch self {
            case .formData:
                return "multipart/form-data"
            case .urlEncodedForm:
                return "application/x-www-form-urlencoded;charset=utf-8"
            case .json:
                return "application/json;charset=utf-8"
            case .plain:
                return "text/plain;charset=utf-8"
            case .other(let value):
                return value
            }
        }
    }
}