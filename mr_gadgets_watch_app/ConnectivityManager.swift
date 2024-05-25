import WatchConnectivity
import Combine

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = ConnectivityManager()
    
    @Published var message: String = ""
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func send(message: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: { response in
                DispatchQueue.main.async {
                    self.message = response["response"] as? String ?? "No response"
                }
            }, errorHandler: { error in
                print("Error sending message: \(error.localizedDescription)")
            })
        } else {
            print("iPhone is not reachable")
        }
    }
    
    // WCSessionDelegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.message = message["request"] as? String ?? "No message"
        }
    }
}
}
