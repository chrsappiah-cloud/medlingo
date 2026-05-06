import SwiftUI

struct MessagingView: View {
    let recipientID: UUID
    let recipientName: String

    @State private var messages: [ChatMessage] = MessagingView.sampleMessages
    @State private var inputText = ""
    @State private var isSending = false
    @State private var showVideoCall = false
    @State private var videoRoomURL: URL?
    @State private var videoToken: String?

    private let currentUserID = UUID()

    init(recipientID: UUID = UUID(), recipientName: String = "Dr. Smith") {
        self.recipientID = recipientID
        self.recipientName = recipientName
    }

    var body: some View {
        VStack(spacing: 0) {
            messagesList
            inputBar
        }
        .background(AppColor.background)
        .navigationTitle(recipientName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await startVideoCall() }
                } label: {
                    Image(systemName: "video.fill")
                        .foregroundColor(AppColor.diamond)
                }
            }
        }
        .fullScreenCover(isPresented: $showVideoCall) {
            if let url = videoRoomURL, let token = videoToken {
                let session = TutorSession(
                    id: UUID(), tutorID: recipientID, title: "Call with \(recipientName)",
                    description: nil, startsAt: Date(), durationMinutes: 30,
                    priceCents: 0, seatsAvailable: 2, seatsBooked: 1,
                    chapterIDs: [], status: .live
                )
                SessionRoomView(session: session, roomURL: url, token: token)
            }
        }
    }

    private func startVideoCall() async {
        let sessionID = UUID()
        if let result = await DataMiddleware.shared.createSessionRoom(sessionID: sessionID) {
            videoRoomURL = result.url
            videoToken = result.token
            showVideoCall = true
        }
    }

    // MARK: - Messages List

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(messages) { message in
                        messageBubble(for: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
            }
            .onChange(of: messages.count) {
                if let last = messages.last {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func messageBubble(for message: ChatMessage) -> some View {
        let isSent = message.senderID == currentUserID
        return HStack(alignment: .bottom, spacing: AppSpacing.xs) {
            if isSent { Spacer(minLength: 60) }

            VStack(alignment: isSent ? .trailing : .leading, spacing: AppSpacing.xxs) {
                Text(message.content)
                    .font(AppTypography.body)
                    .foregroundColor(isSent ? AppColor.primaryDark : AppColor.textPrimary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(isSent ? AppColor.gold : AppColor.surface)
                    .clipShape(ChatBubbleShape(isSent: isSent))

                HStack(spacing: AppSpacing.xxs) {
                    Text(formattedTime(message.sentAt))
                        .font(AppTypography.caption2)
                        .foregroundColor(AppColor.textTertiary)
                    if isSent {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 10))
                            .foregroundColor(message.isRead ? AppColor.emerald : AppColor.textTertiary)
                    }
                }
            }

            if !isSent { Spacer(minLength: 60) }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: AppSpacing.sm) {
            TextField("Message...", text: $inputText, axis: .vertical)
                .font(AppTypography.body)
                .foregroundColor(AppColor.textPrimary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
                .lineLimit(1...4)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? AppColor.textTertiary : AppColor.gold)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColor.surfaceElevated)
    }

    // MARK: - Actions

    private func sendMessage() {
        let content = inputText.trimmingCharacters(in: .whitespaces)
        guard !content.isEmpty else { return }

        isSending = true
        inputText = ""

        Task {
            await DataMiddleware.shared.sendMessage(to: recipientID, content: content)
            let newMessage = ChatMessage(
                id: UUID(),
                senderID: currentUserID,
                recipientID: recipientID,
                content: content,
                sentAt: Date(),
                readAt: nil,
                attachmentURL: nil
            )
            messages.append(newMessage)
            isSending = false
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Sample Data

    private static let sampleMessages: [ChatMessage] = {
        let tutor = UUID()
        let learner = UUID()
        return [
            ChatMessage(id: UUID(), senderID: tutor, recipientID: learner, content: "Hello! How can I help you today?", sentAt: Date().addingTimeInterval(-3600), readAt: Date().addingTimeInterval(-3500), attachmentURL: nil),
            ChatMessage(id: UUID(), senderID: learner, recipientID: tutor, content: "Hi Dr. Smith! I'm struggling with cardiovascular terminology.", sentAt: Date().addingTimeInterval(-3400), readAt: Date().addingTimeInterval(-3300), attachmentURL: nil),
            ChatMessage(id: UUID(), senderID: tutor, recipientID: learner, content: "No problem! Let's start with the root 'cardi' which means heart. Combined with prefixes and suffixes it forms many terms.", sentAt: Date().addingTimeInterval(-3200), readAt: Date().addingTimeInterval(-3100), attachmentURL: nil),
            ChatMessage(id: UUID(), senderID: learner, recipientID: tutor, content: "That makes sense. What about 'pericardium'?", sentAt: Date().addingTimeInterval(-1800), readAt: nil, attachmentURL: nil),
        ]
    }()
}

// MARK: - Chat Bubble Shape

struct ChatBubbleShape: Shape {
    let isSent: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let tailSize: CGFloat = 6

        var path = Path()

        if isSent {
            path.addRoundedRect(
                in: CGRect(x: rect.minX, y: rect.minY, width: rect.width - tailSize, height: rect.height),
                cornerSize: CGSize(width: radius, height: radius)
            )
            path.move(to: CGPoint(x: rect.maxX - tailSize, y: rect.maxY - radius))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - tailSize - 8, y: rect.maxY))
        } else {
            path.addRoundedRect(
                in: CGRect(x: rect.minX + tailSize, y: rect.minY, width: rect.width - tailSize, height: rect.height),
                cornerSize: CGSize(width: radius, height: radius)
            )
            path.move(to: CGPoint(x: rect.minX + tailSize, y: rect.maxY - radius))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + tailSize + 8, y: rect.maxY))
        }

        return path
    }
}

#Preview {
    NavigationStack {
        MessagingView()
    }
}
