import XCTest
@testable import Wire

final class Base64UtilsTests: XCTestCase {
    func testEncodeUTF8String() throws {
        XCTAssertEqual(
            try Base64Utils.base64String(from: "Hello, World!", stringEncoding: .utf8, base64EncodingOptions: []),
            "SGVsbG8sIFdvcmxkIQ=="
        )
        XCTAssertEqual(
            try Base64Utils.base64Data(from: "Hello, World!", stringEncoding: .utf8, base64EncodingOptions: []),
            try base64Data()
        )
    }

    func testDecodeBase64Data() throws {
        XCTAssertEqual(
            try Base64Utils.string(using: try base64Data(), stringEncoding: .utf8, base64DecodingOptions: []),
            "Hello, World!"
        )
        XCTAssertEqual(
            try Base64Utils.data(using: try base64Data(), base64DecodingOptions: []),
            try utf8Data()
        )
    }

    private func utf8Data() throws -> Data {
        try XCTUnwrap("Hello, World!".data(using: .utf8))
    }

    private func base64Data() throws -> Data {
        try XCTUnwrap("SGVsbG8sIFdvcmxkIQ==".data(using: .utf8))
    }
}
