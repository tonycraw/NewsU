import SwiftUI

struct NewPrayerRequestView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var category: PrayerCategory = .guidance
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ZStack {
                NewsUTheme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What's on your heart?")
                            .font(.newsUTitle)
                            .foregroundStyle(NewsUTheme.ink)
                        Text("This stays private to you — it's just between you and this space.")
                            .font(.newsUCaption)
                            .foregroundStyle(NewsUTheme.inkSecondary)
                    }

                    TextEditor(text: $text)
                        .font(.newsUBody)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(height: 160)
                        .newsUCard()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("CATEGORY")
                            .font(.caption2.weight(.semibold))
                            .tracking(1)
                            .foregroundStyle(NewsUTheme.inkFaint)

                        FlowLayout(spacing: 10) {
                            ForEach(PrayerCategory.allCases) { option in
                                CategoryChip(category: option, isSelected: category == option) {
                                    category = option
                                }
                            }
                        }
                    }

                    Spacer()

                    PrimaryButton(
                        title: isSubmitting ? "Saving…" : "Save Prayer Request",
                        isEnabled: !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
                    ) {
                        isSubmitting = true
                        Task {
                            await appState.submitPrayerRequest(text: text, category: category)
                            dismiss()
                        }
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private struct CategoryChip: View {
    let category: PrayerCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(category.label, systemImage: category.sfSymbol)
                .font(.newsUCaption.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .foregroundStyle(isSelected ? .white : NewsUTheme.ink)
                .background(isSelected ? NewsUTheme.gold : NewsUTheme.surface)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(isSelected ? .clear : NewsUTheme.divider, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NewPrayerRequestView().environmentObject(AppState())
}
