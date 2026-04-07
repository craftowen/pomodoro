import XCTest
@testable import Pomodoro

final class InlineSettingsViewTests: XCTestCase {
    func testKeyboardShortcutsRecorderSupportReturnsFalseWhenBundleIsMissing() {
        let bundleURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        XCTAssertFalse(KeyboardShortcutsRecorderSupport.isAvailable(in: bundleURL))
    }

    func testKeyboardShortcutsRecorderSupportReturnsTrueWhenBundleExists() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let bundleURL = rootURL.appendingPathComponent(KeyboardShortcutsRecorderSupport.resourceBundleName, isDirectory: true)

        try FileManager.default.createDirectory(at: bundleURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: rootURL) }

        XCTAssertTrue(KeyboardShortcutsRecorderSupport.isAvailable(in: rootURL))
    }
}
