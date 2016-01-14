import XCTest

class RegularExpressionTest: XCTestCase {

  var re: RegularExpression?

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testEmpty() {
    re = RegularExpression(expr: "")
    XCTAssertTrue(re!.test(""), "should accept empty string")
    XCTAssertFalse(re!.test("0"))
  }

  func testSingleLiteral() {
    re = RegularExpression(expr: "1")
    XCTAssertTrue(re!.test("1"), "should accept single literal as the expression")
    XCTAssertFalse(re!.test("0"))
  }

  func testContinuousLiterals() {
    let expr = "10101"
    re = RegularExpression(expr: expr)
    XCTAssertTrue(re!.test(expr), "should accept original building expression")
    XCTAssertFalse(re!.test("101011"))
    XCTAssertFalse(re!.test("1010"))
  }
}
