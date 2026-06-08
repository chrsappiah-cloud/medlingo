import Testing
import Foundation
@testable import medlingo

struct KeyValueStoreFakeTests {
    var store: KeyValueStoreFake

    init() {
        store = KeyValueStoreFake()
    }

    @Test func bool_defaultIsFalse() {
        #expect(store.bool(forKey: "nonexistent") == false)
    }

    @Test func bool_returnsSetValue() {
        store.set(true, forKey: "dark_mode")
        #expect(store.bool(forKey: "dark_mode") == true)
    }

    @Test func bool_afterReset_returnsFalse() {
        store.set(true, forKey: "dark_mode")
        store.reset()
        #expect(store.bool(forKey: "dark_mode") == false)
    }

    @Test func string_returnsSetValue() {
        store.set("hello", forKey: "greeting")
        #expect(store.string(forKey: "greeting") == "hello")
    }

    @Test func string_nilForMissingKey() {
        #expect(store.string(forKey: "missing") == nil)
    }

    @Test func string_overwritesValue() {
        store.set("first", forKey: "key")
        store.set("second", forKey: "key")
        #expect(store.string(forKey: "key") == "second")
    }

    @Test func data_returnsSetValue() {
        let data = "test".data(using: .utf8)!
        store.set(data, forKey: "cached")
        #expect(store.data(forKey: "cached") == data)
    }

    @Test func removeObject_removesValue() {
        store.set("value", forKey: "key")
        store.removeObject(forKey: "key")
        #expect(store.string(forKey: "key") == nil)
    }

    @Test func reset_clearsAllValues() {
        store.set(true, forKey: "flag")
        store.set("text", forKey: "text")
        store.reset()
        #expect(store.dictionaryRepresentation().isEmpty)
    }

    @Test func multipleKeys_canBeStored() {
        store.set("value1", forKey: "key1")
        store.set("value2", forKey: "key2")
        #expect(store.dictionaryRepresentation().count == 2)
    }
}
