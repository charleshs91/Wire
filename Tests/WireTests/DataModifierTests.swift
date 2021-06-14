import XCTest
@testable import Wire

final class DataModifierTests: XCTestCase {
    func testInit() {
        let dataModifier = AnyDataModifiable { data -> Result<Data, Error> in
            return .success("Modified".data(using: .utf8) ?? Data())
        }
        let data = try? dataModifier.modify(Data()).get()
        XCTAssertNotNil(data)
        XCTAssertEqual(data, "Modified".data(using: .utf8))
    }

    func testFailure() {
        let dataModifier = AnyDataModifiable(StubModifier())
        XCTAssertThrowsError(try dataModifier.modify(Data()).get(), "") { error in
            XCTAssertEqual(error as? TestError, .failure)
        }
    }
}

private struct StubModifier: DataModifiable {
    func modify(_ inputData: Data) -> Result<Data, Error> {
        return .failure(TestError.failure)
    }
}
