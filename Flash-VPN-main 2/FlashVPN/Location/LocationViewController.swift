import UIKit
import NetworkExtension

class LocationViewController: UIViewController, UITextFieldDelegate {
   
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchview: UIView!
    @IBOutlet weak var locationTableView: UITableView!
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    var search = String()
    var configData: [ServerList] = []
    var searchData: [ServerList] = []
    
    override func viewDidLoad() {
        self.searchview.clipsToBounds = true
        self.searchview.layer.cornerRadius = searchview.layer.frame.height/2
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(UINib(nibName: "LocationViewPrimaryCell", bundle: nil), forCellReuseIdentifier: "LocationCell")
        self.searchField.delegate = self
        self.searchField.addTarget(self, action: #selector(searchWorkersAsPerText(_ :)), for: .editingChanged)
        if let data = configModel?.serverList {
            configData = data
            searchData = configData
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func searchWorkersAsPerText(_ textfield:UITextField) {
        self.searchData.removeAll()
        if textfield.text?.count != 0 {
            for dicData in self.configData {
                let isMachingWorker : NSString = (dicData.location ?? "") as NSString
                let range = isMachingWorker.lowercased.range(of: textfield.text!, options: NSString.CompareOptions.caseInsensitive, range: nil,   locale: nil)
                if range != nil {
                    searchData.append(dicData)
                }
            }
        } else {
            self.searchData = self.configData
        }
        self.locationTableView.reloadData()
    }
}

extension LocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return searchData.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = self.view.backgroundColor
        let label = UILabel()
        label.frame = CGRect.init(x: 25, y: 5, width: headerView.frame.width-10, height: headerView.frame.height)
        switch section {
        case 0:
            label.text = "Free"
        case 1:
            label.text = ""
        default:
            return nil
        }
        
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
//        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationViewPrimaryCell
            if indexPath.row == UserDefaults.standard.integer(forKey: "pickedCellRow") && indexPath.section == UserDefaults.standard.integer(forKey: "pickedCellSection") {
                cell.LocationIndicator.image = UIImage(named: "pickedItem")
            } else {
                cell.LocationIndicator.image = UIImage(named: "unpickedItem")
            }
            cell.locationImage.image = UIImage(named: "optimal")
            cell.locationTitle.text = "Optimal Location"
            cell.markStatus(status: .signal4)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationViewPrimaryCell
            configureCell(cell: cell, index: indexPath)
            return cell
        }
    }
    
    func configureCell(cell: LocationViewPrimaryCell, index: IndexPath) {
        if index.row == UserDefaults.standard.integer(forKey: "pickedCellRow") && index.section == UserDefaults.standard.integer(forKey: "pickedCellSection") {
            cell.LocationIndicator.image = UIImage(named: "pickedItem")
        } else {
            cell.LocationIndicator.image = UIImage(named: "unpickedItem")
        }
        
        let item = searchData[index.row]
        cell.selectionStyle = .none
        cell.locationTitle.text = item.location
        if let imageName = item.imagename {
            cell.locationImage.downloaded(from: imageName)
        }
        if let ip = item.ip {
            cell.getUsageStat(server: ip)
            cell.setupCellIndicator()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if NEVPNManager.shared().connection.status == .connected || NEVPNManager.shared().connection.status == .connecting {
            vpnManager.disconnectVPN()
        }
        UserDefaults.standard.setValue(indexPath.row, forKey: "pickedCellRow")
        UserDefaults.standard.setValue(indexPath.section, forKey: "pickedCellSection")
        switch indexPath.section {
        case 0:
            getOptimalServer()
            dismiss(animated: true, completion: nil)
        default:
                let item = searchData[indexPath.row]
                UserDefaults.standard.setValue(item.location, forKey: "vpnLocation")
                UserDefaults.standard.setValue(item.imagename, forKey: "imagename")
                UserDefaults.standard.setValue(item.username, forKey: "vpnUsername")
                UserDefaults.standard.setValue(item.ip, forKey: "vpnServer")
                UserDefaults.standard.setValue(item.id, forKey: "vpnID")
                UserDefaults.standard.setValue(item.pass, forKey: "vpnPass")
                dismiss(animated: true, completion: nil)
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
