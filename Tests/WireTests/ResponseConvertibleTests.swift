import XCTest
@testable import Wire

final class ResponseConvertibleTests: XCTestCase {
    func testInit() throws {
        let converter = AnyResponseConverter<String> { data in
            let aString = String(data: data, encoding: .utf8) ?? ""
            return .success(aString)
        }
        let payload = #function.data(using: .utf8) ?? Data()
        let string = try converter.convert(data: payload).get()

        XCTAssertEqual(string, #function)
    }

    func testSuccess() throws {
        let converter = AnyResponseConverter(StringIntConverter())
        let payload = "100".data(using: .utf8) ?? Data()
        let number = try converter.convert(data: payload).get()

        XCTAssertEqual(number, 100)
    }

    func testFailure() {
        let converter = AnyResponseConverter(StringIntConverter())
        let payload = #function.data(using: .utf8) ?? Data()

        XCTAssertThrowsError(try converter.convert(data: payload).get(), "") { error in
            XCTAssertEqual(error as? TestError, .failure)
        }
    }
}

private struct StringIntConverter: ResponseConvertible {
    func convert(data: Data) -> Result<Int, Error> {
        guard let aString = String(data: data, encoding: .utf8),
              let intValue = Int(aString) else {
            return .failure(TestError.failure)
        }
        return .success(intValue)
    }
}
