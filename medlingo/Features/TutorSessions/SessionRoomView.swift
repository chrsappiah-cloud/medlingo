import SwiftUI
import WebKit

struct SessionRoomView: View {
    let session: TutorSession
    let roomURL: URL
    let token: String

    @Environment(\.dismiss) private var dismiss
    @State private var isConnected = false
    @State private var elapsedMinutes = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            sessionHeader
            DailyVideoWebView(roomURL: roomURL, token: token, isConnected: $isConnected)
                .ignoresSafeArea(edges: .bottom)
        }
        .background(AppColor.background)
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(isConnected ? AppColor.emerald : AppColor.error)
                        .frame(width: 8, height: 8)
                    Text(isConnected ? "Connected" : "Connecting...")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.textSecondary)
                    Text("• \(elapsedMinutes) min")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.textTertiary)
                }
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColor.error)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task { @MainActor in elapsedMinutes += 1 }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct DailyVideoWebView: UIViewRepresentable {
    let roomURL: URL
    let token: String
    @Binding var isConnected: Bool

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false

        var urlComponents = URLComponents(url: roomURL, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: "t", value: token)]
        if let url = urlComponents.url {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: DailyVideoWebView

        init(_ parent: DailyVideoWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                parent.isConnected = true
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                parent.isConnected = false
            }
        }
    }
}
