import Foundation
import PlainPing

class ServerUsageTracker {
    var pings = [String]()
    var isEnded = false {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("goToVC"), object: nil)
        }
    }
    
    func pingNext() {
        guard pings.count > 0 else {
            isEnded = true
            return
        }

        let ping = pings.removeFirst()
        PlainPing.ping(ping, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                usage[ping] = latency
            }
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
            self.pingNext()
        })
    }
    
}
