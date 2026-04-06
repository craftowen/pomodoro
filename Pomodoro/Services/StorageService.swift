import Foundation

struct StorageService {
    private static var appSupportURL: URL {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Pomodoro", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func save<T: Encodable>(_ data: T, to filename: String) {
        let url = appSupportURL.appendingPathComponent(filename)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(data) else { return }
        try? jsonData.write(to: url, options: .atomic)
    }

    static func load<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        let url = appSupportURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(type, from: data)
    }

    static func delete(_ filename: String) {
        let url = appSupportURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}
