import Foundation
import NetworkExtension

class VPNPSK {
    let vpnManager = NEVPNManager.shared()
    
    private var vpnLoadHandler: (Error?) -> Void { return
        { (error:Error?) in
            if ((error) != nil) {
                print("Could not load VPN Configurations")
                return;
            }
            let protocolIKEv2 = NEVPNProtocolIKEv2()
            let kcs = KeychainService()
            kcs.save(key: "vpnPass", value: UserDefaults.standard.string(forKey: "vpnPass") ?? "")
            protocolIKEv2.passwordReference = kcs.load(key: "vpnPass")
            protocolIKEv2.username = UserDefaults.standard.string(forKey: "vpnUsername")
            protocolIKEv2.serverAddress = UserDefaults.standard.string(forKey: "vpnServer")
            protocolIKEv2.remoteIdentifier = UserDefaults.standard.string(forKey: "serverID")
            protocolIKEv2.localIdentifier = UserDefaults.standard.string(forKey: "serverID")
            protocolIKEv2.useExtendedAuthentication = true
            protocolIKEv2.disconnectOnSleep = false
            protocolIKEv2.disableMOBIKE = false
            protocolIKEv2.disableRedirect = false
            protocolIKEv2.enableRevocationCheck = false
            protocolIKEv2.useConfigurationAttributeInternalIPSubnet = false
            protocolIKEv2.authenticationMethod = .none
            protocolIKEv2.deadPeerDetectionRate = .medium
            protocolIKEv2.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256GCM
            protocolIKEv2.childSecurityAssociationParameters.integrityAlgorithm = .SHA384
            protocolIKEv2.childSecurityAssociationParameters.diffieHellmanGroup = .group20
            protocolIKEv2.childSecurityAssociationParameters.lifetimeMinutes = 1440
            protocolIKEv2.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256GCM
            protocolIKEv2.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA384
            protocolIKEv2.ikeSecurityAssociationParameters.diffieHellmanGroup = .group20
            protocolIKEv2.ikeSecurityAssociationParameters.lifetimeMinutes = 1440
            self.vpnManager.protocolConfiguration = protocolIKEv2
            self.vpnManager.localizedDescription = "Flash VPN"
            self.vpnManager.isEnabled = true
            self.vpnManager.saveToPreferences(completionHandler: self.vpnSaveHandler)
        }
    }
    
    private var vpnSaveHandler: (Error?) -> Void { return
        { (error:Error?) in
            if (error != nil) {
                print("Could not save VPN Configurations")
                return
            } else {
                do {
                    try self.vpnManager.connection.startVPNTunnel()
                } catch let error {
                    print("Error starting VPN Connection \(error.localizedDescription)");
                }
            }
        }
    }
    
    public func connectVPN() {
        self.vpnManager.loadFromPreferences(completionHandler: self.vpnLoadHandler)
    }
    
    
    public func disconnectVPN() ->Void {
        vpnManager.connection.stopVPNTunnel()
    }
    
}
