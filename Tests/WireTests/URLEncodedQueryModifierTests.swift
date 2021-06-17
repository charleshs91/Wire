import XCTest
@testable import Wire

final class URLEncodedQueryModifierTests: XCTestCase {
    func test_queryToURLPath() throws {
        let modifier = URLEncodedQueryModifier(parameters: ["say": "台灣難波萬"], destination: .queryString)

        let origReq = URLRequest(url: URL(string: "http://www.example.com/api")!)
        let newReq = try modifier.modify(origReq).get()

        XCTAssertEqual(newReq.url?.query, "say=%E5%8F%B0%E7%81%A3%E9%9B%A3%E6%B3%A2%E8%90%AC")
    }

    func test_queryToFormBody() throws {
        let modifier = URLEncodedQueryModifier(parameters: ["say": "台灣難波萬"], destination: .httpBody)

        let origReq = URLRequest(url: URL(string: "http://www.example.com/api")!)
        let newReq = try modifier.modify(origReq).get()

        XCTAssertEqual(newReq.httpBody?.utf8String(), "say=%E5%8F%B0%E7%81%A3%E9%9B%A3%E6%B3%A2%E8%90%AC")
    }
}
