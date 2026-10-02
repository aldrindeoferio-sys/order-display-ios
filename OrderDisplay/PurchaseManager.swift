import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let premiumProductID = "com.deoferioapps.orderdisplay.premium"

    @Published private(set) var isPremium = false
    @Published private(set) var product: Product?
    @Published var errorMessage: String?

    func loadProduct() async {
        do { product = try await Product.products(for: [Self.premiumProductID]).first }
        catch { errorMessage = error.localizedDescription }
    }

    func refreshEntitlements() async {
        var premium = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == Self.premiumProductID && transaction.revocationDate == nil {
                premium = true
            }
        }
        isPremium = premium
        if product == nil { await loadProduct() }
    }

    func purchasePremium() async {
        if product == nil { await loadProduct() }
        guard let product else { return }
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                await transaction.finish()
                await refreshEntitlements()
            }
        } catch { errorMessage = error.localizedDescription }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch { errorMessage = error.localizedDescription }
    }
}
