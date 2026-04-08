import WatchConnectivity
import SlipieCoreKit
import Foundation

final class WatchConnectivityBridge: NSObject, WCSessionDelegate, @unchecked Sendable {
    static let shared = WatchConnectivityBridge()

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func send(packet: BiometricPacket) {
        guard WCSession.default.isReachable else { return }
        do {
            let data = try JSONEncoder().encode(packet)
            WCSession.default.sendMessageData(data, replyHandler: nil, errorHandler: nil)
        } catch {}
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}
}
