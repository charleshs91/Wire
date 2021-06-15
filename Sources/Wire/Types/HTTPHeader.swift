import Foundation

/// Represents a HTTP header field.
public struct HTTPHeader: RequestHeader {
    public let key: String
    public let value: String
    public let mergesField: Bool

    public init(key: String, value: String, mergesField: Bool = true) {
        self.key = key
        self.value = value
        self.mergesField = mergesField
    }

    public static func accept(_ contentType: ContentType) -> HTTPHeader {
        HTTPHeader(key: "Accept", value: contentType.value)
    }

    public static func acceptCharset(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Accept-Charset", value: value)
    }

    public static func acceptEncoding(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Accept-Encoding", value: value)
    }

    public static func acceptLanguage(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Accept-Language", value: value)
    }

    public static func acceptDateTime(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Accept-Datetime", value: value)
    }

    public static func authorization(_ authorization: Authorization) -> HTTPHeader {
        authorization.asHTTPHeader
    }

    public static func cacheControl(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Cache-Control", value: value)
    }

    public static func connection(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Connection", value: value)
    }

    public static func cookie(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Cookie", value: value)
    }

    public static func contentType(_ contentType: ContentType) -> HTTPHeader {
        contentType.asHTTPHeader
    }

    public static func contentMD5(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Content-MD5", value: value)
    }

    public static func date(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Date", value: value)
    }

    public static func expect(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Expect", value: value)
    }

    public static func from(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "From", value: value)
    }

    public static func ifMatch(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "If-Match", value: value)
    }

    public static func keepAlive(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Keep-Alive", value: value)
    }

    public static func referer(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "Referer", value: value)
    }

    public static func userAgent(_ value: String) -> HTTPHeader {
        HTTPHeader(key: "User-Agent", value: value)
    }
}

private extension RequestHeader {
    var asHTTPHeader: HTTPHeader {
        HTTPHeader(key: key, value: value, mergesField: mergesField)
    }
}
