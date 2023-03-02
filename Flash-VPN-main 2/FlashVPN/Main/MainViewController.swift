//
//  MainViewController.swift
//  FlashVPN
//
//  Created by Алексей Трушковский on 13.08.2021.
//

import UIKit
import NetworkExtension
import SpeedcheckerSDK
import CoreLocation
import Lottie
import Windless

let vpnManager = VPNPSK()
var usage = [String: Double]()

class MainViewController: UIViewController {
    
    private var internetTest: InternetSpeedTest?
    private var locationManager = CLLocationManager()
    private var timer = Timer()
    private var isFirstEnter = false
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIStackView!
    @IBOutlet weak var connectionHint: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var speedtestView: UIStackView!
    @IBOutlet weak var downloadSpeed: UILabel!
    @IBOutlet weak var uploadSpeed: UILabel!
    @IBOutlet weak var connectionTimeLabel: UILabel!
    @IBOutlet weak var locationViewFlag: UIImageView!
    @IBOutlet weak var locationViewName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDisconnectedState()
        setupVpn()
        setupUI()
        scheduledTimerWithTimeInterval()
        internetTest = InternetSpeedTest(delegate: self)
        uploadSpeed.layer.cornerRadius = uploadSpeed.layer.frame.height/2
        uploadSpeed.layer.masksToBounds = true
        downloadSpeed.layer.cornerRadius = downloadSpeed.layer.frame.height/2
        downloadSpeed.layer.masksToBounds = true
        self.uploadSpeed.windless.apply { config in
            config.animationBackgroundColor = self.view.backgroundColor ?? .clear
            config.animationLayerColor = UIColor(red: 57.0/255.0, green: 72.0/255.0, blue: 129.0/255.0, alpha: 1.0)
            config.pauseDuration = 0
            config.duration = 2
        }
        self.downloadSpeed.windless.apply { config in
            config.animationBackgroundColor = self.view.backgroundColor ?? .clear
            config.animationLayerColor = UIColor(red: 57.0/255.0, green: 72.0/255.0, blue: 129.0/255.0, alpha: 1.0)
            config.pauseDuration = 0
            config.duration = 2
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillLayoutSubviews() {
        setupCurrentLocationView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: "confirmed") {
            fetchRemoteConfig(completion: {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "landing", sender: nil)
                }
            })
        }
    }
    
    func startConnectingAnimation() {
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [.autoreverse, .repeat], animations: {
            self.connectButton.alpha = 0.5
        },completion: nil )
    }
    
    func stopConnectingAnimation() {
        self.connectButton.alpha = 1
        self.connectButton.layer.removeAllAnimations()
    }
    
    func startSpeedTestAnimation() {
        uploadSpeed.text = ""
        downloadSpeed.text = ""
        uploadSpeed.windless.start()
        downloadSpeed.windless.start()
    }
    
    func setupDisconnectedState() {
        stopConnectingAnimation()
        connectionTimeLabel.isHidden = true
        connectButton.setImage(UIImage(named: "connectButton"), for: .normal)
        statusLabel.text = "Disconnected"
        locationView.alpha = 1
        startSpeedTestAnimation()
        connectionHint.isHidden = false
        internetTest?.startTest() { (error) in
            print(error)
        }
    }
    
    func setupConnectingState() {
        startConnectingAnimation()
        connectionTimeLabel.isHidden = true
        connectButton.setImage(UIImage(named: "connectButton"), for: .normal)
        statusLabel.text = "Connecting"
        locationView.alpha = 0.6
        startSpeedTestAnimation()
        connectionHint.isHidden = true
        internetTest?.startTest() { (error) in
            print(error)
        }
    }
    
    func setupDisconnectingState() {
        startConnectingAnimation()
        connectionTimeLabel.isHidden = true
        connectButton.setImage(UIImage(named: "connectButton"), for: .normal)
        statusLabel.text = "Disconnecting"
        locationView.alpha = 0.6
        startSpeedTestAnimation()
        connectionHint.isHidden = true
        internetTest?.startTest() { (error) in
            print(error)
        }
    }
    
    func setupConnectedState() {
        stopConnectingAnimation()
        connectionTimeLabel.text = "00:00:00"
        connectionTimeLabel.isHidden = false
        connectButton.setImage(UIImage(named: "connectedButton"), for: .normal)
        statusLabel.text = "Connected"
        locationView.alpha = 1
        startSpeedTestAnimation()
        connectionHint.isHidden = true
        internetTest?.startTest() { (error) in
            print(error)
        }
    }
    
    
    @IBAction func connectButtonAction(_ sender: UIButton) {
        if NEVPNManager.shared().connection.status == .connecting {
            return
        } else if NEVPNManager.shared().connection.status == .connected {
            vpnManager.disconnectVPN()
        } else {
            if UserDefaults.standard.string(forKey: "vpnLocation") == "Optimal" {
                getOptimalServer()
            }
            vpnManager.connectVPN()
        }
    }
    
    
    
    func scheduledTimerWithTimeInterval() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting() {
        if let connectedDate = NEVPNManager.shared().connection.connectedDate {
            connectionTimeLabel.text = Date().offsetFrom(date: connectedDate)
        }
    }
    
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        locationView.addGestureRecognizer(tapGesture)
        locationView.clipsToBounds = true
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "toLocation", sender: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        setupCurrentLocationView()
    }
    
    func setupVpn(){
        vpnManager.vpnManager.loadFromPreferences { (error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                self.checkNEStatus(status: NEVPNManager.shared().connection.status)
            }
        }
        UserDefaults.standard.addObserver(self, forKeyPath: "vpnLocation", options: NSKeyValueObservingOptions.new, context: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil, queue: nil, using: { notification in
            let nevpnconn = notification.object as! NEVPNConnection
            let status = nevpnconn.status
            self.checkNEStatus(status: status)
        })
        
        if UserDefaults.standard.string(forKey: "vpnLocation") == nil {
            getOptimalServer()
        }
    }
    
    func setupCurrentLocationView() {
        locationView.backgroundColor = UIColor(red: 50.0/255.0, green: 61.0/255.0, blue: 122.0/255.0, alpha: 1.0)
        locationView.layer.cornerRadius = locationView.layer.frame.height/2
        guard let name = UserDefaults.standard.string(forKey: "vpnLocation") else { return }
        guard let imagename = UserDefaults.standard.string(forKey: "imagename") else { return }
        locationViewName.text = name
        if imagename != "optimal" {
            locationViewFlag.downloaded(from: imagename)
        } else {
            locationViewFlag.image = UIImage(named: "optimal")
        }
        
    }
    
    func checkNEStatus( status:NEVPNStatus ) {
        switch status {
        case NEVPNStatus.invalid:
            print("NEVPNConnection: Invalid")
            setupDisconnectedState()
            isFirstEnter = true
        case NEVPNStatus.disconnected:
            print("NEVPNConnection: Disconnected")
            setupDisconnectedState()
            if isFirstEnter {
                vpnManager.connectVPN()
                isFirstEnter = false
            }
        case NEVPNStatus.connecting:
            print("NEVPNConnection: Connecting")
            setupConnectingState()
        case NEVPNStatus.connected:
            print("NEVPNConnection: Connected")
            setupConnectedState()
        case NEVPNStatus.reasserting:
            print("NEVPNConnection: Reasserting")
        case NEVPNStatus.disconnecting:
            setupDisconnectingState()
            print("NEVPNConnection: Disconnecting")
        @unknown default:
            print("NEVPNConnection: Unknown Error")
        }
    }
    
}


extension Date {
    func offsetFrom(date: Date) -> String {
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self)
        
        var seconds = "\(difference.second ?? 0)"
        var minutes = "\(difference.minute ?? 0)"
        var hours = "\(difference.hour ?? 0)"
        
        if hours.count == 1 {
            hours = "0\(hours)"
        }
        if minutes.count == 1 {
            minutes = "0\(minutes)"
        }
        if seconds.count == 1 {
            seconds = "0\(seconds)"
        }
        return hours + ":" + minutes + ":" + seconds
    }
}

extension MainViewController: InternetSpeedTestDelegate {
    func internetTestError(error: SpeedTestError) {}
    func internetTestFinish(result: SpeedTestResult) {}
    func internetTestReceived(servers: [SpeedTestServer]) {}
    func internetTestSelected(server: SpeedTestServer, latency: Int, jitter: Int) {}
    func internetTestDownloadStart() {}
    func internetTestDownloadFinish() {}
    func internetTestDownload(progress: Double, speed: SpeedTestSpeed) {
        DispatchQueue.main.async {
            self.downloadSpeed.text = speed.descriptionInMbps
            self.downloadSpeed.windless.end()
        }
    }
    func internetTestUploadStart() {}
    func internetTestUploadFinish() {}
    func internetTestUpload(progress: Double, speed: SpeedTestSpeed) {
        DispatchQueue.main.async {
            self.uploadSpeed.text = speed.descriptionInMbps
            self.uploadSpeed.windless.end()
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {}
