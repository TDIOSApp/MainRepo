import Foundation

var configModel: ConfigModel?

struct ConfigModel: Codable {
    let pages: [Page]?
    let buttonText: String?
    let fmode: Bool?
    let alternateLink, alternateConfirmation: String?
    let serverList: [ServerList]?
}

struct Page: Codable {
    let image: String?
    let title, desc: String?
}

struct ServerList: Codable {
    let location: String?
    let imagename: String?
    let ip, username, pass, id: String?
}

func fetchRemoteConfig(completion: @escaping() -> ()) {
    remoteConfig.fetch(withExpirationDuration: 0) { (status, error) in
        guard error == nil else { return completion() }
        print("Got the value from Remote Config!")
        remoteConfig.activate()
        configModel = getConfigValue()
        completion()
    }
}

func getConfigValue() -> ConfigModel? {
    let configValue = remoteConfig.configValue(forKey: "config").dataValue
    do {
        let result = try JSONDecoder().decode(ConfigModel.self, from: configValue)
        return result
    } catch {
        return nil
    }
}
