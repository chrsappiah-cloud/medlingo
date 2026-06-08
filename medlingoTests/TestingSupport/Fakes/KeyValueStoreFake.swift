import Foundation

protocol KeyValueStore {
    func bool(forKey defaultName: String) -> Bool
    func string(forKey defaultName: String) -> String?
    func data(forKey defaultName: String) -> Data?
    func set(_ value: Any?, forKey defaultName: String)
    func removeObject(forKey defaultName: String)
    func reset()
    func dictionaryRepresentation() -> [String: Any]
}

final class KeyValueStoreFake: KeyValueStore {
    private var storage: [String: Any] = [:]

    func bool(forKey defaultName: String) -> Bool {
        storage[defaultName] as? Bool ?? false
    }

    func string(forKey defaultName: String) -> String? {
        storage[defaultName] as? String
    }

    func data(forKey defaultName: String) -> Data? {
        storage[defaultName] as? Data
    }

    func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }

    func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }

    func reset() {
        storage.removeAll()
    }

    func dictionaryRepresentation() -> [String: Any] {
        storage
    }
}
