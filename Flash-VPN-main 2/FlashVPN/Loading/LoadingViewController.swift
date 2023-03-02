//
//  ViewController.swift
//  FlashVPN
//
//  Created by Алексей Трушковский on 12.08.2021.
//

import UIKit
import ApphudSDK
import Lottie
import Firebase
import FirebaseAnalytics

class LoadingViewController: UIViewController {
    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.redirect), name: Notification.Name("goToVC"), object: nil)
        lottieAnimationInit(animView: animationView)
        fetchRemoteConfig(completion: {
            self.usageReqest()
        })
    }
    
    @objc private func redirect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            if UserDefaults.standard.bool(forKey: "isFirst"){
                self.performSegue(withIdentifier: "main", sender: nil)
            } else {
                self.performSegue(withIdentifier: "privacy", sender: nil)
                UserDefaults.standard.setValue(true, forKey: "isFirst")
            }
        })
    }
    
    func usageReqest() {
        guard let config = configModel?.serverList else { return }
        var servers = [String]()
        for item in config {
            if let ip = item.ip {
                servers.append(ip)
            }
        }
        let tracker = ServerUsageTracker()
        tracker.pings = servers
        tracker.pingNext()
    }
}
