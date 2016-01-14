import XCTest

class RegularExpressionTest: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testEmpty() {
    let re = RegularExpression(expr: "")
    XCTAssertTrue(re.test(""), "should accept empty string")
    XCTAssertFalse(re.test("0"))
  }

  func testSingleLiteral() {
    let re = RegularExpression(expr: "1")
    XCTAssertTrue(re.test("1"), "should accept single literal as the expression")
    XCTAssertFalse(re.test(""))
    XCTAssertFalse(re.test("0"))
  }

  func testStrings() {
    let expr = "10101"
    let re = RegularExpression(expr: expr)
    XCTAssertTrue(re.test(expr), "should accept original building expression")
    XCTAssertFalse(re.test(""))
    XCTAssertFalse(re.test("101011"))
    XCTAssertFalse(re.test("1010"))
  }

  func testUnionOnSingleLiteral() {
    let re = RegularExpression(expr: "1+0")
    XCTAssertTrue(re.test("0"), "should accept one of the two patterns")
    XCTAssertTrue(re.test("1"), "should accept another one of the two patterns")
    XCTAssertFalse(re.test("10"))
    XCTAssertFalse(re.test("01"))
    XCTAssertFalse(re.test(""))
  }

  func testUnionOnMultipleStrings() {
    let re = RegularExpression(expr: "101+0011+1110")
    XCTAssertTrue(re.test("101"))
    XCTAssertTrue(re.test("0011"))
    XCTAssertTrue(re.test("1110"))
    XCTAssertFalse(re.test("1"))
    XCTAssertFalse(re.test("0"))
    XCTAssertFalse(re.test("100"))
    XCTAssertFalse(re.test("00"))
    XCTAssertFalse(re.test("1111"))
  }
}
