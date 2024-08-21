import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "e28bb268-ae85-4e0e-8074-d7e1b16ea07a") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    func didOpenMainScreen() {
        report(event: "open", params: ["screen": "Main"])
    }
    func didCloseMainScreen() {
        report(event: "close", params: ["screen": "Main"])
    }
    func didClickAddTrack() {
        report(event: "click", params: ["screen": "Main", "item": "add_track"])
    }
    func didClickFilter() {
        report(event: "click", params: ["screen": "Main", "item": "filter"])
    }
    func didClickDelete() {
        report(event: "click", params: ["screen": "Main", "item": "delete"])
    }
    func didTapTrackerOnMain() {
        report(event: "click", params: ["screen": "Main", "item": "track"])
    }
    func didClickEdit() {
        report(event: "click", params: ["screen": "Main", "item": "edit"])
    }
    private func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
