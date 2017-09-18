import XCTest
@testable import EventsTree

struct TestEvent: Event {}
struct WrongEvent: Event {}

class EventsTreeTests: XCTestCase {

  static var allTests = [
    ("eventCanBeHandledOnPropagate", testEventCanBeHandledOnPropagate),
    ]

  func testEventCanBeHandledOnPropagate() {
    let node = EventNode(parent: nil)
    let expectation = XCTestExpectation(description: "Event is captured")
    node.addHandler { (event: TestEvent) in
      expectation.fulfill()
    }
    node.raise(event: TestEvent())

    let result = XCTWaiter().wait(for: [expectation], timeout: 0.1)

    XCTAssert(result == .completed, "Event isn't captured")
  }

  func testWrongEventCantBeHandledOnPropagate() {
    let node = EventNode(parent: nil)
    let expectation = XCTestExpectation(description: "Event isn't captured")
    expectation.isInverted = true
    node.addHandler { (event: TestEvent) in
      expectation.fulfill()
    }
    node.raise(event: WrongEvent())

    let result = XCTWaiter().wait(for: [expectation], timeout: 0.1)

    XCTAssert(result == .completed, "Wrong event is captured")
  }

  func testEventCantBeHandledAfterHandlerDeletion() {
    let node = EventNode(parent: nil)
    let expectation = XCTestExpectation(description: "Event isn't captured")
    expectation.isInverted = true
    node.addHandler { (event: TestEvent) in
      expectation.fulfill()
    }
    node.removeHandlers(for: TestEvent.self)
    node.raise(event: TestEvent())

    let result = XCTWaiter().wait(for: [expectation], timeout: 0.1)

    XCTAssert(result == .completed, "Deleted event is captured")
  }

}
