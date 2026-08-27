import Foundation
import StoreKit

enum StoreError: Error {
    case failedVerification
}

/// Wraps StoreKit 2. This is real subscription code, not a mock — it reads
/// products from `Subscription.storekit` (see project root) when running from
/// Xcode with that file set as the scheme's StoreKit Configuration, which is
/// how you test purchases in Simulator with zero App Store Connect setup.
///
/// To ship this for real: create matching subscription products in App Store
/// Connect (same product IDs), and this same code starts talking to the real
/// App Store automatically — nothing else changes.
@MainActor
final class StoreKitManager: ObservableObject {
    static let productIDs = [
        "com.newsu.app.plus.monthly",
        "com.newsu.app.plus.annual"
    ]

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoadingProducts = false
    @Published var purchaseError: String?

    var isSubscribed: Bool { !purchasedProductIDs.isEmpty }

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            products = try await Product.products(for: Self.productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            purchaseError = "Couldn't load subscription plans. Check your connection and try again."
        }
    }

    func purchase(_ product: Product) async {
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await refreshEntitlements()
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = "Purchase failed. Please try again."
        }
    }

    func restorePurchases() async {
        purchaseError = nil
        do {
            try await AppStore.sync()
        } catch {
            purchaseError = "Couldn't restore purchases. Please try again."
        }
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var activeIDs: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                activeIDs.insert(transaction.productID)
            }
        }
        purchasedProductIDs = activeIDs
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if let transaction = try? await self.checkVerified(result) {
                    await self.refreshEntitlements()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
