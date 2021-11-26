import Foundation

public struct Base64DataToStringConverter: ResponseConvertible {
    let base64DecodingOptions: Data.Base64DecodingOptions
    let stringEncoding: String.Encoding

    public init(base64DecodingOptions: Data.Base64DecodingOptions, stringEncoding: String.Encoding) {
        self.base64DecodingOptions = base64DecodingOptions
        self.stringEncoding = stringEncoding
    }

    public func convert(data: Data) -> Result<String, Swift.Error> {
        Result(catching: {
            try Base64Utils.string(
                using: data,
                stringEncoding: stringEncoding,
                base64DecodingOptions: base64DecodingOptions
            )
        })
    }
}
