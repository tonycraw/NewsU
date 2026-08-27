import SwiftUI
import StoreKit

struct SubscriptionPaywallView: View {
    @EnvironmentObject var store: StoreKitManager
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false

    var body: some View {
        ZStack {
            NewsUTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.largeTitle)
                            .foregroundStyle(NewsUTheme.gold)
                        Text("NewsU Plus")
                            .font(.newsUDisplay)
                            .foregroundStyle(NewsUTheme.ink)
                        Text("Unlock your full daily brief — every topic, every prayer, every verse.")
                            .font(.newsUBody)
                            .foregroundStyle(NewsUTheme.inkSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 14) {
                        FeatureRow(icon: "sparkles", text: "Unlimited AI-curated topics")
                        FeatureRow(icon: "hands.sparkles.fill", text: "Daily guided prayer")
                        FeatureRow(icon: "book.closed.fill", text: "A verse for every story")
                        FeatureRow(icon: "text.bubble.fill", text: "Submit private prayer requests")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .newsUCard()
                    .padding(.horizontal, 20)

                    if store.isLoadingProducts {
                        ProgressView().padding(.top, 20)
                    } else if store.products.isEmpty {
                        Text("Subscription plans aren't available right now. Pull down to try again, or check your connection.")
                            .font(.newsUCaption)
                            .foregroundStyle(NewsUTheme.inkSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(store.products, id: \.id) { product in
                                PlanCard(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id,
                                    isBestValue: product.id == StoreKitManager.productIDs.last
                                ) {
                                    selectedProduct = product
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    if let error = store.purchaseError {
                        Text(error)
                            .font(.newsUCaption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    VStack(spacing: 14) {
                        PrimaryButton(
                            title: isPurchasing ? "Please wait…" : "Continue",
                            isEnabled: selectedProduct != nil && !isPurchasing,
                            action: purchase
                        )

                        Button {
                            Task { await store.restorePurchases() }
                        } label: {
                            Text("Restore Purchases")
                                .font(.newsUCaption.weight(.medium))
                                .foregroundStyle(NewsUTheme.inkSecondary)
                        }
                    }
                    .padding(.horizontal, 20)

                    legalFooter
                }
                .padding(.bottom, 40)
            }
        }
        .onChange(of: store.products) { _, products in
            if selectedProduct == nil {
                selectedProduct = products.first(where: { $0.id == StoreKitManager.productIDs.last }) ?? products.first
            }
        }
    }

    private var legalFooter: some View {
        VStack(spacing: 6) {
            Text("Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in Settings > Apple ID > Subscriptions.")
                .font(.caption2)
                .foregroundStyle(NewsUTheme.inkFaint)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            HStack(spacing: 16) {
                Link("Terms of Use", destination: URL(string: "https://newsu.app/terms")!)
                Link("Privacy Policy", destination: URL(string: "https://newsu.app/privacy")!)
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(NewsUTheme.gold)
        }
        .padding(.top, 6)
    }

    private func purchase() {
        guard let product = selectedProduct else { return }
        isPurchasing = true
        Task {
            await store.purchase(product)
            isPurchasing = false
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(NewsUTheme.gold)
                .frame(width: 28)
            Text(text)
                .font(.newsUBody)
                .foregroundStyle(NewsUTheme.ink)
        }
    }
}

private struct PlanCard: View {
    let product: Product
    let isSelected: Bool
    let isBestValue: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? NewsUTheme.gold : NewsUTheme.inkFaint)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(.newsUBody.weight(.semibold))
                            .foregroundStyle(NewsUTheme.ink)
                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(NewsUTheme.gold)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(product.description)
                        .font(.newsUCaption)
                        .foregroundStyle(NewsUTheme.inkSecondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.newsUBody.weight(.bold))
                    .foregroundStyle(NewsUTheme.ink)
            }
            .padding(16)
            .background(NewsUTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? NewsUTheme.gold : NewsUTheme.divider, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SubscriptionPaywallView()
        .environmentObject(AppState())
        .environmentObject(StoreKitManager())
}
