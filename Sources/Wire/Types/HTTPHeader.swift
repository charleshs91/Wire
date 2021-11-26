import Foundation

/// Represents a HTTP header field.
public struct HTTPHeader: RequestHeader {
    public let key: String
    public let value: String
    public let mergesField: Bool

    public init(key: String, value: String, mergesField: Bool = false) {
        self.key = key
        self.value = value
        self.mergesField = mergesField
    }

    public static func accept(_ contentType: ContentType, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Accept", value: contentType.value, mergesField: mergesField)
    }

    public static func acceptCharset(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Accept-Charset", value: value, mergesField: mergesField)
    }

    public static func acceptEncoding(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Accept-Encoding", value: value, mergesField: mergesField)
    }

    public static func acceptLanguage(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Accept-Language", value: value, mergesField: mergesField)
    }

    public static func acceptDateTime(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Accept-Datetime", value: value, mergesField: mergesField)
    }

    public static func authorization(_ authorization: Authorization) -> HTTPHeader {
        authorization.asHTTPHeader
    }

    public static func cacheControl(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Cache-Control", value: value, mergesField: mergesField)
    }

    public static func connection(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Connection", value: value, mergesField: mergesField)
    }

    public static func cookie(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Cookie", value: value, mergesField: mergesField)
    }

    public static func contentType(_ contentType: ContentType) -> HTTPHeader {
        contentType.asHTTPHeader
    }

    public static func contentMD5(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Content-MD5", value: value, mergesField: mergesField)
    }

    public static func date(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Date", value: value, mergesField: mergesField)
    }

    public static func expect(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Expect", value: value, mergesField: mergesField)
    }

    public static func from(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "From", value: value, mergesField: mergesField)
    }

    public static func ifMatch(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "If-Match", value: value, mergesField: mergesField)
    }

    public static func keepAlive(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Keep-Alive", value: value, mergesField: mergesField)
    }

    public static func referer(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "Referer", value: value, mergesField: mergesField)
    }

    public static func userAgent(_ value: String, mergesField: Bool = false) -> HTTPHeader {
        HTTPHeader(key: "User-Agent", value: value, mergesField: mergesField)
    }
}

extension RequestHeader {
    fileprivate var asHTTPHeader: HTTPHeader {
        HTTPHeader(key: key, value: value, mergesField: mergesField)
    }
}
