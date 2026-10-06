import Foundation
import UserMessagingPlatform

@MainActor
final class ConsentManager: ObservableObject {
    @Published private(set) var canRequestAds = false
    @Published private(set) var privacyOptionsRequired = false
    @Published var errorMessage: String?

    func requestConsent() async {
        let parameters = RequestParameters()
        do {
            try await ConsentInformation.shared.requestConsentInfoUpdate(with: parameters)
            privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required

            if ConsentInformation.shared.formStatus == .available {
                try await ConsentForm.loadAndPresentIfRequired(from: nil)
            }

            canRequestAds = ConsentInformation.shared.canRequestAds
            privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        } catch {
            errorMessage = error.localizedDescription
            canRequestAds = ConsentInformation.shared.canRequestAds
        }
    }

    func presentPrivacyOptions() async {
        do {
            try await ConsentForm.presentPrivacyOptionsForm(from: nil)
            canRequestAds = ConsentInformation.shared.canRequestAds
            privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
