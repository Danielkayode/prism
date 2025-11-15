import XCTest

final class InlineChatFlowUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testInlineChatAppearance() {
        let inlineChatButton = app.buttons["Inline Chat"]
        XCTAssertTrue(inlineChatButton.exists)
        
        inlineChatButton.tap()
        
        let inlineChatOverlay = app.otherElements["Inline AI"]
        XCTAssertTrue(inlineChatOverlay.waitForExistence(timeout: 2))
    }
    
    func testModeSelectorChanges() {
        let modePicker = app.segmentedControls["Mode"]
        XCTAssertTrue(modePicker.exists)
        
        modePicker.buttons["Agent"].tap()
        XCTAssertTrue(modePicker.buttons["Agent"].isSelected)
    }
    
    func testChatMessageSend() {
        let messageField = app.textFields["Message..."]
        XCTAssertTrue(messageField.exists)
        
        messageField.tap()
        messageField.typeText("Hello Prism")
        
        app.buttons.matching(identifier: "paperplane.fill").element.tap()
        
        XCTAssertTrue(app.staticTexts["Hello Prism"].waitForExistence(timeout: 2))
    }
}
