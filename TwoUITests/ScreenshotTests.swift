import XCTest

final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()
    var screenshotDir: String {
        let subdir: String
        if let content = try? String(contentsOfFile: "/tmp/screenshot_subdir.txt", encoding: .utf8),
           !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            subdir = content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            subdir = "Screenshots"
        }
        return "/Users/sadygsadygov/Desktop/new_dom/Two/\(subdir)"
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func saveScreenshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let data = screenshot.pngRepresentation
        let url = URL(fileURLWithPath: "\(screenshotDir)/\(name).png")
        try? data.write(to: url)
    }

    @MainActor
    func testCaptureAllScreenshots() throws {
        try? FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)

        app.launchArguments = ["-hasCompletedOnboarding", "NO"]
        app.launch()
        sleep(3)
        saveScreenshot("01-onboarding-vehicle-info")

        let nextBtn = app.buttons["Next"]
        if nextBtn.waitForExistence(timeout: 3) {
            nextBtn.tap()
            sleep(2)
            saveScreenshot("02-onboarding-mileage")

            if nextBtn.waitForExistence(timeout: 3) {
                nextBtn.tap()
                sleep(2)
                saveScreenshot("03-onboarding-fuel-type")
            }
        }

        app.terminate()
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
        sleep(3)
        saveScreenshot("04-empty-garage")

        let addBtn = app.buttons["Add Vehicle"]
        if addBtn.waitForExistence(timeout: 3) {
            addBtn.tap()
            sleep(2)
            saveScreenshot("05-add-vehicle-sheet")

            let nameField = app.textFields["Nickname (e.g., My Honda)"]
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("BMW 330i")
            }
            let makeField = app.textFields["Make (e.g., Honda)"]
            if makeField.waitForExistence(timeout: 2) {
                makeField.tap()
                makeField.typeText("BMW")
            }
            let modelField = app.textFields["Model (e.g., Civic)"]
            if modelField.waitForExistence(timeout: 2) {
                modelField.tap()
                modelField.typeText("330i")
            }

            saveScreenshot("06-add-vehicle-form")

            let saveBtn = app.buttons["Save"]
            if saveBtn.waitForExistence(timeout: 3) {
                saveBtn.tap()
                sleep(3)
            }
        }

        app.terminate()
        app.launchArguments = ["-hasCompletedOnboarding", "YES"]
        app.launch()
        sleep(4)

        let vehicleCell = app.staticTexts["BMW 330i"]
        if vehicleCell.waitForExistence(timeout: 3) && vehicleCell.isHittable {
            vehicleCell.tap()
            sleep(2)
        }

        saveScreenshot("07-car-dashboard")

        let fillUpPred = NSPredicate(format: "label CONTAINS[c] 'Fill-Up' OR label CONTAINS[c] 'Fill Up'")
        let fillUpBtn = app.buttons.matching(fillUpPred).firstMatch

        let window = app.windows.firstMatch
        window.swipeUp()
        sleep(1)
        saveScreenshot("08-dashboard-gauges")

        if fillUpBtn.waitForExistence(timeout: 5) {
            fillUpBtn.tap()
            sleep(2)
            saveScreenshot("09-add-fillup-sheet")

            let cancelBtn = app.navigationBars.buttons["Cancel"]
            if cancelBtn.waitForExistence(timeout: 3) {
                cancelBtn.tap()
                sleep(1)
            } else {
                app.buttons["Cancel"].tap()
                sleep(1)
            }
        }

        let servicePred = NSPredicate(format: "label CONTAINS[c] 'Service' OR label CONTAINS[c] 'Maintenance'")
        let serviceBtn = app.buttons.matching(servicePred).firstMatch
        if serviceBtn.waitForExistence(timeout: 5) {
            serviceBtn.tap()
            sleep(2)
            saveScreenshot("10-add-service-sheet")

            let cancelBtn2 = app.navigationBars.buttons["Cancel"]
            if cancelBtn2.waitForExistence(timeout: 3) {
                cancelBtn2.tap()
                sleep(1)
            } else {
                app.buttons["Cancel"].tap()
                sleep(1)
            }
        }

        window.swipeUp()
        sleep(1)
        saveScreenshot("11-dashboard-statistics")

        window.swipeUp()
        sleep(1)
        saveScreenshot("12-dashboard-maintenance")

        let backPred = NSPredicate(format: "label CONTAINS[c] 'Garage' OR label CONTAINS[c] 'Back'")
        let backBtn = app.navigationBars.buttons.matching(backPred).firstMatch
        if backBtn.waitForExistence(timeout: 3) {
            backBtn.tap()
            sleep(2)
        } else {
            let firstNavBtn = app.navigationBars.buttons.element(boundBy: 0)
            if firstNavBtn.waitForExistence(timeout: 2) {
                firstNavBtn.tap()
                sleep(2)
            }
        }

        let settingsPred = NSPredicate(format: "label CONTAINS[c] 'gearshape' OR label CONTAINS[c] 'Settings' OR label CONTAINS[c] 'gear'")
        let settingsBtn = app.buttons.matching(settingsPred).firstMatch
        if settingsBtn.waitForExistence(timeout: 5) {
            settingsBtn.tap()
            sleep(2)
            saveScreenshot("13-settings")

            window.swipeUp()
            sleep(1)
            saveScreenshot("14-settings-detail")
        }
    }
}
