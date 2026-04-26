import Foundation
import Observation
import RevenueCat

@Observable
@MainActor
class StoreViewModel {
    var offerings: Offerings?
    var isPremium: Bool = false
    var isLoading: Bool = false
    var isPurchasing: Bool = false
    var error: String?

    init() {
        Task { await listenForUpdates() }
        Task { await fetchOfferings() }
    }

    private func listenForUpdates() async {
        for await info in Purchases.shared.customerInfoStream {
            self.isPremium = info.entitlements["premium"]?.isActive == true
        }
    }

    func fetchOfferings() async {
        isLoading = true
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            self.error = Self.friendlyMessage(for: error)
        }
        isLoading = false
    }

    func purchase(package: Package) async {
        isPurchasing = true
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                isPremium = result.customerInfo.entitlements["premium"]?.isActive == true
            }
        } catch ErrorCode.purchaseCancelledError {
        } catch ErrorCode.paymentPendingError {
        } catch {
            self.error = Self.friendlyMessage(for: error)
        }
        isPurchasing = false
    }

    func restore() async {
        do {
            let info = try await Purchases.shared.restorePurchases()
            isPremium = info.entitlements["premium"]?.isActive == true
        } catch {
            self.error = Self.friendlyMessage(for: error)
        }
    }

    func checkStatus() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            isPremium = info.entitlements["premium"]?.isActive == true
        } catch {
            self.error = Self.friendlyMessage(for: error)
        }
    }

    private static func friendlyMessage(for error: Error) -> String {
        let nsError = error as NSError
        if let code = ErrorCode(rawValue: nsError.code) {
            switch code {
            case .networkError, .offlineConnectionError:
                return "You appear to be offline. Check your connection and try again."
            case .productNotAvailableForPurchaseError,
                 .productAlreadyPurchasedError,
                 .productDiscountMissingIdentifierError,
                 .productDiscountMissingSubscriptionGroupIdentifierError,
                 .configurationError,
                 .unexpectedBackendResponseError,
                 .receiptInUseByOtherSubscriberError,
                 .invalidAppUserIdError,
                 .invalidCredentialsError,
                 .operationAlreadyInProgressForProductError,
                 .unknownBackendError:
                return "Subscriptions are temporarily unavailable. Please try again in a moment."
            case .storeProblemError, .ineligibleError, .invalidReceiptError:
                return "The App Store reported a problem. Please try again shortly."
            case .paymentPendingError:
                return "Your purchase is pending approval. We'll unlock Pro as soon as it's confirmed."
            case .missingReceiptFileError:
                return "We couldn't find a purchase receipt. Try Restore Purchases or sign in to the App Store."
            default:
                break
            }
        }
        return "Something went wrong. Please try again."
    }
}
