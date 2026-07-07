import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [EscrowtrackItem] = []
    @Published var isPro: Bool = false

    static let freeLimit = 20

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("escrowtrack_items.json")
    }()

    init() {
        load()
        if items.isEmpty {
            items = Store.seedData()
            save()
        }
    }

    static func seedData() -> [EscrowtrackItem] {
        [
        EscrowtrackItem(title: "Apartment deposit", amount: 1500.0)
        ]
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: EscrowtrackItem) {
        guard canAddMore else { return }
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: EscrowtrackItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: EscrowtrackItem) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([EscrowtrackItem].self, from: data) {
            items = decoded
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
