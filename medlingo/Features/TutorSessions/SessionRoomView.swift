import SwiftUI
import WebKit

struct SessionRoomView: View {
    let session: TutorSession
    let roomURL: URL
    let token: String

    @Environment(\.dismiss) private var dismiss
    @State private var isConnected = false
    @State private var isMuted = false
    @State private var isCameraOff = false
    @State private var elapsedMinutes = 0
    @State private var connectionError: String?
    @State private var timer: Timer?
    @State private var showEndConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            sessionHeader
            if let error = connectionError {
                errorView(error)
            } else {
                DailyVideoWebView(roomURL: roomURL, token: token, isConnected: $isConnected, connectionError: $connectionError)
                    .ignoresSafeArea(edges: .bottom)
            }
            controlBar
        }
        .background(AppColor.background)
        .preferredColorScheme(.dark)
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .alert("End Session?", isPresented: $showEndConfirmation) {
            Button("Stay", role: .cancel) {}
            Button("End", role: .destructive) { dismiss() }
        } message: {
            Text("Are you sure you want to leave this session?")
        }
    }

    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColor.textPrimary)
                    .lineLimit(1)
                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(isConnected ? AppColor.emerald : AppColor.streakOrange)
                        .frame(width: 8, height: 8)
                        .shadow(color: (isConnected ? AppColor.emerald : AppColor.streakOrange).opacity(0.6), radius: 3)
                    Text(isConnected ? "Connected" : "Connecting...")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColor.textSecondary)
                    if isConnected {
                        Text("• \(elapsedMinutes) min")
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColor.textTertiary)
                    }
                }
            }
            Spacer()
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(AppColor.diamond)
                Text("\(session.seatsBooked + 1)")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColor.textSecondary)
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(AppColor.surfaceElevated)
            .clipShape(Capsule())
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
    }

    private var controlBar: some View {
        HStack(spacing: AppSpacing.xl) {
            controlButton(icon: isMuted ? "mic.slash.fill" : "mic.fill", isActive: !isMuted, color: isMuted ? AppColor.error : AppColor.textPrimary) {
                isMuted.toggle()
            }

            controlButton(icon: isCameraOff ? "video.slash.fill" : "video.fill", isActive: !isCameraOff, color: isCameraOff ? AppColor.error : AppColor.textPrimary) {
                isCameraOff.toggle()
            }

            controlButton(icon: "message.fill", isActive: true, color: AppColor.diamond) {}

            controlButton(icon: "rectangle.on.rectangle", isActive: true, color: AppColor.gold) {}

            Button {
                showEndConfirmation = true
            } label: {
                Image(systemName: "phone.down.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(AppColor.error)
                    .clipShape(Circle())
                    .shadow(color: AppColor.error.opacity(0.4), radius: 6)
            }
        }
        .padding(.vertical, AppSpacing.md)
        .padding(.horizontal, AppSpacing.lg)
        .background(AppColor.surface)
    }

    private func controlButton(icon: String, isActive: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(isActive ? AppColor.surfaceElevated : AppColor.error.opacity(0.2))
                .clipShape(Circle())
        }
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 56))
                .foregroundColor(AppColor.error)
            Text("Connection Failed")
                .font(AppTypography.title2)
                .foregroundColor(AppColor.textPrimary)
            Text(error)
                .font(AppTypography.body)
                .foregroundColor(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Retry") {
                connectionError = nil
            }
            .frame(width: 150)
            SecondaryButton(title: "Leave") { dismiss() }
                .frame(width: 150)
            Spacer()
        }
        .padding(AppSpacing.lg)
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
    @Binding var connectionError: String?

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
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + [URLQueryItem(name: "t", value: token)]
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
                parent.connectionError = nil
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                parent.isConnected = false
                parent.connectionError = error.localizedDescription
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                parent.isConnected = false
                parent.connectionError = "Unable to connect: \(error.localizedDescription)"
            }
        }
    }
}
