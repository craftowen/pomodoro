import XCTest
@testable import Pomodoro

final class UpdaterServiceTests: XCTestCase {
    func testEmptyFeedIsNotUsable() {
        let xml = """
        <?xml version="1.0" encoding="utf-8"?>
        <rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
            <channel>
                <title>Pomodoro Updates</title>
                <language>en</language>
            </channel>
        </rss>
        """

        XCTAssertFalse(UpdateFeedValidator.hasUsableUpdateItem(in: xml))
    }

    func testSignedFeedItemIsUsable() {
        let xml = """
        <?xml version="1.0" encoding="utf-8"?>
        <rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
            <channel>
                <title>Pomodoro Updates</title>
                <item>
                    <title>Version 0.1.0</title>
                    <sparkle:version>1</sparkle:version>
                    <sparkle:shortVersionString>0.1.0</sparkle:shortVersionString>
                    <enclosure
                        url="https://github.com/craftowen/pomodoro/releases/download/v0.1.0/Pomodoro.app.zip"
                        sparkle:edSignature="signed-value"
                        length="328656"
                        type="application/octet-stream"/>
                </item>
            </channel>
        </rss>
        """

        XCTAssertTrue(UpdateFeedValidator.hasUsableUpdateItem(in: xml))
    }
}
