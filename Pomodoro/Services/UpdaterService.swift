import Foundation
import Sparkle
import Combine

enum UpdateFeedValidator {
    static func hasUsableUpdateItem(in data: Data) -> Bool {
        guard let xml = String(data: data, encoding: .utf8) else { return false }
        return hasUsableUpdateItem(in: xml)
    }

    static func hasUsableUpdateItem(in xml: String) -> Bool {
        xml.contains("<item")
            && xml.contains("<enclosure")
            && xml.contains("sparkle:edSignature=")
    }
}

@Observable
@MainActor
final class UpdaterService {
    private let updaterController: SPUStandardUpdaterController
    private var cancellable: AnyCancellable?
    private var feedValidationTask: Task<Void, Never>?
    private var sparkleCanCheckForUpdates = false
    private var hasUsableFeed = false

    var canCheckForUpdates = false

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        sparkleCanCheckForUpdates = updaterController.updater.canCheckForUpdates
        cancellable = updaterController.updater.publisher(for: \.canCheckForUpdates)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.sparkleCanCheckForUpdates = value
                self?.updateCheckAvailability()
            }
        feedValidationTask = Task { [weak self] in
            await self?.refreshFeedAvailability()
        }
        updateCheckAvailability()
    }

    func checkForUpdates() {
        Task { [weak self] in
            guard let self else { return }
            await self.refreshFeedAvailability()
            guard self.canCheckForUpdates else { return }
            self.updaterController.checkForUpdates(nil)
        }
    }

    private func updateCheckAvailability() {
        canCheckForUpdates = sparkleCanCheckForUpdates && hasUsableFeed
    }

    private func refreshFeedAvailability() async {
        guard
            let feedURLString = Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String,
            let feedURL = URL(string: feedURLString)
        else {
            hasUsableFeed = false
            updateCheckAvailability()
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: feedURL)
            guard !Task.isCancelled else { return }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
            hasUsableFeed = (200...299).contains(statusCode) && UpdateFeedValidator.hasUsableUpdateItem(in: data)
        } catch {
            hasUsableFeed = false
        }

        updateCheckAvailability()
    }
}
