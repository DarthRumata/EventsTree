import XCTest
@testable import EventsTree

struct TestEvent: Event {}

class EventsTreeTests: XCTestCase {

  static var allTests = [
    ("eventCanBeHandledOnPropagate", testEventCanBeHandledOnPropagate),
    ]

  func testEventCanBeHandledOnPropagate() {
    let node = EventNode(parent: nil)
    let expectation = XCTestExpectation(description: "Event is captured")
    expectation.expectedFulfillmentCount = 1
    node.addHandler { (event: TestEvent) in
      expectation.fulfill()
    }
    node.raise(event: TestEvent())

    let result = XCTWaiter().wait(for: [expectation], timeout: 0.1)

    XCTAssert(result == .completed, "Event isn't captured")
  }

}
