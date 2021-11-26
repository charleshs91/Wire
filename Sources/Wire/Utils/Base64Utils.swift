import Foundation

public struct Base64Utils {
    public enum Error: LocalizedError {
        case stringEncodingMismatch
        case inputNotBase64Encoded
    }

    public static func string(using base64Data: Data, stringEncoding: String.Encoding, base64DecodingOptions: Data.Base64DecodingOptions) throws -> String {
        guard let data = Data(base64Encoded: base64Data, options: base64DecodingOptions) else {
            throw Error.inputNotBase64Encoded
        }
        guard let output = String(data: data, encoding: stringEncoding) else {
            throw Error.stringEncodingMismatch
        }
        return output
    }

    public static func data(using base64Data: Data, base64DecodingOptions: Data.Base64DecodingOptions) throws -> Data {
        guard let output = Data(base64Encoded: base64Data, options: base64DecodingOptions) else {
            throw Error.inputNotBase64Encoded
        }
        return output
    }

    public static func base64String(from string: String, stringEncoding: String.Encoding, base64EncodingOptions: Data.Base64EncodingOptions) throws -> String {
        guard let output = string.data(using: stringEncoding)?.base64EncodedString(options: base64EncodingOptions) else {
            throw Error.stringEncodingMismatch
        }
        return output
    }

    public static func base64Data(from string: String, stringEncoding: String.Encoding, base64EncodingOptions: Data.Base64EncodingOptions) throws -> Data {
        guard let output = string.data(using: stringEncoding)?.base64EncodedData(options: base64EncodingOptions) else {
            throw Error.stringEncodingMismatch
        }
        return output
    }
}
