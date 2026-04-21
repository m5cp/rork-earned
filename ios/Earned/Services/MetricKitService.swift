import Foundation
import MetricKit

@MainActor
final class MetricKitService: NSObject {
    static let shared = MetricKitService()

    private let diagnosticsKey = "metricKitDiagnostics"
    private let maxStoredReports = 20

    private override init() {
        super.init()
    }

    func start() {
        MXMetricManager.shared.add(self)
    }

    func recentReports(limit: Int = 20) -> [String] {
        let stored = UserDefaults.standard.stringArray(forKey: diagnosticsKey) ?? []
        return Array(stored.suffix(limit).reversed())
    }

    fileprivate func storeReport(_ summary: String) {
        var reports = UserDefaults.standard.stringArray(forKey: diagnosticsKey) ?? []
        reports.append(summary)
        if reports.count > maxStoredReports {
            reports = Array(reports.suffix(maxStoredReports))
        }
        UserDefaults.standard.set(reports, forKey: diagnosticsKey)
    }
}

extension MetricKitService: MXMetricManagerSubscriber {
    nonisolated func didReceive(_ payloads: [MXDiagnosticPayload]) {
        let summaries: [String] = payloads.map { payload in
            let crashCount = payload.crashDiagnostics?.count ?? 0
            let hangCount = payload.hangDiagnostics?.count ?? 0
            let cpuCount = payload.cpuExceptionDiagnostics?.count ?? 0
            let begin = payload.timeStampBegin
            return "\(begin.ISO8601Format()) crashes=\(crashCount) hangs=\(hangCount) cpu=\(cpuCount)"
        }
        Task { @MainActor in
            for summary in summaries {
                MetricKitService.shared.storeReport(summary)
            }
        }
    }

    nonisolated func didReceive(_ payloads: [MXMetricPayload]) {}
}
