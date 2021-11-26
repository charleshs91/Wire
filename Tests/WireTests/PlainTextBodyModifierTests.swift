import XCTest
@testable import Wire

final class PlainTextBodyModifierTests: XCTestCase {
    func testModify() throws {
        let plainText = "name=Wire"
        let request = Request<Data>(
            builder: URL.demo,
            requestModifiers: [
                PlainTextBodyModifier(text: plainText, encoding: .utf8)
            ])

        let urlRequest = try request.buildRequest().get()

        XCTAssertEqual(urlRequest.allHTTPHeaderFields?[ContentType.plainText.key], ContentType.plainText.value)
        XCTAssertEqual(urlRequest.httpBody?.utf8String(), plainText)
    }

    func testEncodingFailure() throws {
        let plainText = "name=Wire"
        let request = Request<Data>(
            builder: URL.demo,
            requestModifiers: [
                PlainTextBodyModifier(text: plainText, encoding: .symbol)
            ])

        XCTAssertThrowsError(try request.buildRequest().get(), "Request builder error") { error in
            guard let err = error as? PlainTextBodyModifier.Error,
                  case .encodingFailure = err
            else {
                return XCTFail("Unexpected error")
            }
        }
    }
}
