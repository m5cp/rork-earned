import SwiftUI

struct CoachChatView: View {
    let earnedViewModel: EarnedViewModel
    @State private var chatViewModel = CoachChatViewModel()
    @FocusState private var inputFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(chatViewModel.messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }

                        if chatViewModel.isLoading {
                            typingIndicator
                                .id("typing")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: chatViewModel.messages.count) { _, _ in
                    withAnimation(.smooth(duration: 0.3)) {
                        if chatViewModel.isLoading {
                            proxy.scrollTo("typing", anchor: .bottom)
                        } else if let last = chatViewModel.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            if let error = chatViewModel.error {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                    Text(error)
                        .font(.caption)
                }
                .foregroundStyle(.red)
                .padding(.horizontal)
                .padding(.vertical, 6)
            }

            inputBar
        }
        .navigationTitle("Coach")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            chatViewModel.setup(with: earnedViewModel)
        }
    }

    private func messageBubble(_ message: CoachMessage) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 60) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.role == .user
                            ? AnyShapeStyle(EarnedColors.primaryGradient)
                            : AnyShapeStyle(Color(.secondarySystemBackground))
                    )
                    .clipShape(.rect(cornerRadius: 20, style: .continuous))

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
            }

            if message.role == .assistant { Spacer(minLength: 60) }
        }
    }

    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(.tertiaryLabel))
                        .frame(width: 7, height: 7)
                        .opacity(0.6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 20, style: .continuous))

            Spacer()
        }
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask your coach...", text: $chatViewModel.inputText, axis: .vertical)
                .lineLimit(1...4)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 22))
                .focused($inputFocused)

            Button {
                chatViewModel.sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(
                        chatViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color(.tertiaryLabel)
                            : EarnedColors.accent
                    )
            }
            .disabled(chatViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatViewModel.isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }
}
