//
//  OptimalServer.swift
//  FlashVPN
//
//  Created by Flash VPN on 20.12.2021.
//

import Foundation

var optimalServer: String? = nil

func getOptimalServer() {
    if let config = configModel?.serverList {
        var optimalIP: String? = nil
        var optimalUsage = 9999.0
        for item in config {
            if let ip = item.ip {
                if let usage = usage[ip] {
                    if optimalUsage > usage {
                        optimalUsage = usage
                        optimalIP = ip
                    }
                }
            }
        }
        optimalServer = optimalIP
    }
    saveOptimalLocation()
}

func saveOptimalLocation() {
    if let config = configModel?.serverList {
        if let optimalServer = optimalServer {
            for item in config {
                if item.ip == optimalServer {
                    UserDefaults.standard.setValue("Optimal", forKey: "vpnLocation")
                    UserDefaults.standard.setValue("optimal", forKey: "imagename")
                    UserDefaults.standard.setValue(item.username, forKey: "vpnUsername")
                    UserDefaults.standard.setValue(item.ip, forKey: "vpnServer")
                    UserDefaults.standard.setValue(item.id, forKey: "vpnID")
                    UserDefaults.standard.setValue(item.pass, forKey: "vpnPass")
                    return
                }
            }
        }
        if let optimal = config.randomElement() {
            UserDefaults.standard.setValue("Optimal", forKey: "vpnLocation")
            UserDefaults.standard.setValue("optimal", forKey: "imagename")
            UserDefaults.standard.setValue(optimal.username, forKey: "vpnUsername")
            UserDefaults.standard.setValue(optimal.ip, forKey: "vpnServer")
            UserDefaults.standard.setValue(optimal.id, forKey: "vpnID")
            UserDefaults.standard.setValue(optimal.pass, forKey: "vpnPass")
        }
    }
}
