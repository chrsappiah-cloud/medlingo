import Testing
import Foundation
@testable import medlingo

struct SubscriptionStateTests {
    @Test func entitlement_whenExpired_isNotValid() {
        #expect(TestDataFactory.entitlement(expired: true).isValid == false)
    }

    @Test func entitlement_whenActive_isValid() {
        #expect(TestDataFactory.entitlement(expired: false).isValid == true)
    }
}
