import AppKit
import XCTest

@testable import MiaoYan

final class PrefsWindowControllerTests: XCTestCase {
    func testWindowAppearanceDoesNotOverwriteTheSavedPreviewMode() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let source = try String(contentsOf: root.appendingPathComponent("Controllers/ViewController.swift"), encoding: .utf8)
        let start = try XCTUnwrap(source.range(of: "override func viewDidAppear()"))
        let end = try XCTUnwrap(source.range(of: "private func installLiveResizeObserverIfNeeded", range: start.upperBound..<source.endIndex))
        let appearance = String(source[start.upperBound..<end.lowerBound])
        XCTAssertNil(appearance.range(of: #"sessionPreviewMode\s*=\s*false"#, options: .regularExpression))
        XCTAssertTrue(appearance.contains("enablePreview()"))
    }

    @MainActor
    func testPreferencesWindowTracksAlwaysOnTopSetting() {
        let originalValue = UserDefaultsManagement.alwaysOnTop
        UserDefaultsManagement.alwaysOnTop = true

        let controller = PrefsWindowController()
        controller.show()

        defer {
            controller.window?.orderOut(nil)
            UserDefaultsManagement.alwaysOnTop = originalValue
            NotificationCenter.default.post(name: .alwaysOnTopChanged, object: nil)
        }

        XCTAssertEqual(controller.window?.level, .floating)

        UserDefaultsManagement.alwaysOnTop = false
        NotificationCenter.default.post(name: .alwaysOnTopChanged, object: nil)

        XCTAssertEqual(controller.window?.level, .normal)
    }
}
