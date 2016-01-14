import XCTest

class REAutomataTest: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testEmpty() {
    let re = REAutomata(expr: "")
    XCTAssertTrue(re.test(""), "should accept empty string")
    XCTAssertFalse(re.test("0"))
  }

  func testSingleLiteral() {
    let re = REAutomata(expr: "1")
    XCTAssertTrue(re.test("1"), "should accept single literal as the expression")
    XCTAssertFalse(re.test(""))
    XCTAssertFalse(re.test("0"))
  }

  func testStrings() {
    let expr = "10101"
    let re = REAutomata(expr: expr)
    XCTAssertTrue(re.test(expr), "should accept original building expression")
    XCTAssertFalse(re.test(""))
    XCTAssertFalse(re.test("101011"))
    XCTAssertFalse(re.test("1010"))
  }

  func testUnionOnSingleLiteral() {
    let re = REAutomata(expr: "1|0")
    XCTAssertTrue(re.test("0"), "should accept one of the two patterns")
    XCTAssertTrue(re.test("1"), "should accept another one of the two patterns")
    XCTAssertFalse(re.test("10"))
    XCTAssertFalse(re.test("01"))
    XCTAssertFalse(re.test(""))
  }

  func testUnionOnMultipleStrings() {
    let re = REAutomata(expr: "101|0011|1110")
    XCTAssertTrue(re.test("101"))
    XCTAssertTrue(re.test("0011"))
    XCTAssertTrue(re.test("1110"))
    XCTAssertFalse(re.test("1"))
    XCTAssertFalse(re.test("0"))
    XCTAssertFalse(re.test("100"))
    XCTAssertFalse(re.test("00"))
    XCTAssertFalse(re.test("1111"))
  }

  func testClosure() {
    let re = REAutomata(expr: "01*0")
    XCTAssertTrue(re.test("00"))
    XCTAssertTrue(re.test("010"))
    XCTAssertTrue(re.test("0110"))
    XCTAssertTrue(re.test("01110"))
    XCTAssertFalse(re.test("011"))
    XCTAssertFalse(re.test("1"))
    XCTAssertFalse(re.test("01101"))
  }

  func testBrackets() {
    let re = REAutomata(expr: "1(01)*")
    XCTAssertTrue(re.test("1"))
    XCTAssertTrue(re.test("101"))
    XCTAssertTrue(re.test("10101"))
    XCTAssertTrue(re.test("1010101"))
    XCTAssertFalse(re.test("10"))
    XCTAssertFalse(re.test("01"))
    XCTAssertFalse(re.test("1010"))
    XCTAssertFalse(re.test("1011"))
    XCTAssertFalse(re.test("1010100"))
  }

  func testMultipleOfThree() {
    // Denotes the set of binary numbers that are multiples of 3.
    let re = REAutomata(expr: "(0|(1(01*(00)*0)*1)*)*")
    XCTAssertTrue(re.test(""))
    XCTAssertTrue(re.test("0"))
    XCTAssertTrue(re.test("00"))
    XCTAssertTrue(re.test("11"))
    XCTAssertTrue(re.test("000"))
    XCTAssertTrue(re.test("011"))
    XCTAssertTrue(re.test("110"))
    XCTAssertTrue(re.test("0000"))
    XCTAssertTrue(re.test("0011"))
    XCTAssertTrue(re.test("0110"))
    XCTAssertTrue(re.test("1001"))
    XCTAssertTrue(re.test("1100"))
    XCTAssertTrue(re.test("1111"))
    XCTAssertTrue(re.test("00000"))
    XCTAssertTrue(re.test("0011110100001000111111"))

    XCTAssertFalse(re.test("1"))
    XCTAssertFalse(re.test("10"))
    XCTAssertFalse(re.test("100"))
    XCTAssertFalse(re.test("101"))
    XCTAssertFalse(re.test("1010"))
    XCTAssertFalse(re.test("0111"))
    XCTAssertFalse(re.test("1101"))
  }

  func testPerformance() {
    self.measureBlock {
      let re = REAutomata(expr: "(0|(1(01*(00)*0)*1)*)*")
      for var i = 0; i < 10; i++ {
        re.test("001011101001000011101101110011111111111")
      }
    }
  }
}
