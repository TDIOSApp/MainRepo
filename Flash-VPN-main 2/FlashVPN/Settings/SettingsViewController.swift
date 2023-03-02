//
//  SettingsViewController.swift
//  FlashVPN
//
//  Created by Алексей Трушковский on 13.08.2021.
//

import UIKit
import StoreKit

class SettingsViewController: UIViewController {
 
    @IBOutlet weak var tableView: UITableView!
    let items = ["Rate on the AppStore", "Contact Support", "Share Flash VPN", "Privacy Policy", "Terms of use"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
    }
    
    func cellSelected(index: Int) {
        switch index {
        case 0:
            SKStoreReviewController.requestReview()
        case 1:
            guard let url = URL(string: "https://forms.gle/wjNARiyLSiuZBPtR9") else { return }
            UIApplication.shared.open(url)
        case 2:
            if let name = URL(string: "https://itunes.apple.com/us/app/myapp/id1582432691?ls=1&mt=8"), !name.absoluteString.isEmpty {
              let objectsToShare = [name]
              let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
              self.present(activityVC, animated: true, completion: nil)
            }
        case 3:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "policy")
            self.present(vc, animated: true)
        case 4:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "terms")
            self.present(vc, animated: true)
        default:
            print("not found")
        }
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.settingsTitle.text = items[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelected(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
