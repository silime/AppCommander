//
//  Common.swift
//  Cache
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import Foundation
import SwiftUI

func unsandbox() {
    if #available(iOS 16.2, *) {
        #if targetEnvironment(simulator)
        #else
        // I'm sorry 16.2 dev beta 1 users, you are a vast minority.
        print("Throwing not supported error (mdc patched)")
        UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.", withButton: false)
        #endif
    } else {
        do {
            // TrollStore method
            print("Checking if installed with TrollStore...")
            try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/Caches"), includingPropertiesForKeys: nil)
            print("99% probably installed with TrollStore")
        } catch {
            print("Trying MDC method...")
            // MDC method
            // grant r/w access
            if #available(iOS 15, *) {
                print("Escaping Sandbox...")
                grant_full_disk_access { error in
                    if error != nil {
                        print("Unable to escape sandbox!! Error: ", String(describing: error?.localizedDescription ?? "unknown?!"))
                        UIApplication.shared.alert(title: "Access Error", body: "Error: \(String(describing: error?.localizedDescription))\nPlease close the app and retry.", withButton: false)
                    } else {
                        print("Successfully escaped sandbox!")
                    }
                }
            } else {
                print("Throwing not supported error (too old?!)")
                UIApplication.shared.alert(title: "Exploit Not Supported", body: "Please install via TrollStore")
            }
        }
    }
}
