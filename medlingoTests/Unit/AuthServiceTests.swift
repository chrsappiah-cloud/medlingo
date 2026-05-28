import Testing
import Foundation
@testable import medlingo

@MainActor
struct AuthServiceTests {
    private func makeSUT(
        mock: MockNetworkClient = MockNetworkClient(),
        sessionStore: InMemorySessionStore = InMemorySessionStore()
    ) -> AuthService {
        AuthService(client: mock, sessionStore: sessionStore)
    }

    @Test func signInWithEmail_whenCredentialsInvalid_throws() async {
        let mock = MockNetworkClient()
        mock.requestHandler = { _ in
            throw NetworkError.httpError(statusCode: 400, data: Data())
        }
        let sut = makeSUT(mock: mock)

        await #expect(throws: (any Error).self) {
            try await sut.signInWithEmail(email: "bad@medlingo.com", password: "wrong")
        }
        #expect(sut.isAuthenticated == false)
        #expect(sut.currentUser == nil)
    }

    @Test func signInWithEmail_whenSessionValid_authenticatesAndPersistsTokens() async throws {
        let mock = MockNetworkClient()
        mock.requestHandler = { _ in JSONFixtureLoader.data(named: "auth_session") }
        let store = InMemorySessionStore()
        let sut = makeSUT(mock: mock, sessionStore: store)

        try await sut.signInWithEmail(email: "fixture@medlingo.com", password: "secret")

        #expect(sut.isAuthenticated == true)
        #expect(sut.currentUser?.email == "fixture@medlingo.com")
        #expect(store.loadAccessToken() == "fixture-access-token")
        #expect(store.loadRefreshToken() == "fixture-refresh-token")
    }

    @Test func refreshSession_whenTokenMissing_throwsSessionExpired() async {
        let sut = makeSUT()
        await #expect(throws: AuthError.sessionExpired) {
            try await sut.refreshSession()
        }
    }

    @Test func signOut_whenAuthenticated_clearsSessionStore() async throws {
        let mock = MockNetworkClient()
        mock.requestHandler = { endpoint in
            if endpoint.path.contains("logout") { return Data() }
            return JSONFixtureLoader.data(named: "auth_session")
        }
        let store = InMemorySessionStore()
        let sut = makeSUT(mock: mock, sessionStore: store)

        try await sut.signInWithEmail(email: "fixture@medlingo.com", password: "pw")
        try await sut.signOut()

        #expect(sut.isAuthenticated == false)
        #expect(store.loadRefreshToken() == nil)
        #expect(store.loadAccessToken() == nil)
    }

}
