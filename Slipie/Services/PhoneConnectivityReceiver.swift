import WatchConnectivity
import SlipieCoreKit
import Foundation

final class PhoneConnectivityReceiver: NSObject, WCSessionDelegate, @unchecked Sendable {
    static let shared = PhoneConnectivityReceiver()
    var onPacketReceived: (@Sendable (BiometricPacket) -> Void)?

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        guard let packet = try? JSONDecoder().decode(BiometricPacket.self, from: messageData) else { return }
        onPacketReceived?(packet)
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
