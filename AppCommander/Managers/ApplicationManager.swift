//
//  ApplicationManager.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

import Foundation
import CompressionWrapper
import CoreServices
import Foundation
import MobileCoreServices
import SwiftUI
import AbsoluteSolver

// stolen from appabetical :trolley:
// I do not know how this code works but all I know is that it does.
public class ApplicationManager {
    private static var fm = FileManager.default
    
    private static let systemApplicationsUrl = URL(fileURLWithPath: "/Applications", isDirectory: true)
    private static let userApplicationsUrl = URL(fileURLWithPath: "/var/containers/Bundle/Application", isDirectory: true)
    
    // MARK: - Goofy ahh function
    static var appsinfo :[Appinfo] = [Appinfo]();
    public static func getDataDir(bundleID: String) throws -> URL {
        let fm = FileManager.default
        var returnedurl = URL(string: "none")
        var dirlist = [""]

        do {
            dirlist = try fm.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application")
            // print(dirlist)
        } catch {
            throw "Could not access /var/mobile/Containers/Data/Application.\n\(error.localizedDescription)"
        }
        for appinfo in appsinfo {
            if  appinfo.bundleIdentifier == bundleID && (!appinfo.dataURL.path.contains("none")){
                return appinfo.dataURL
            }
        }
        for dir in dirlist {
            // print(dir)
            let mmpath = "/var/mobile/Containers/Data/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist"
            // print(mmpath)
            do {
                var mmDict: [String: Any]
                if fm.fileExists(atPath: mmpath) {
                    if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                        mmDict = try PropertyListSerialization.propertyList(from: try AbsoluteSolver.readFile(path: mmpath, progress: {message in
                          //  print(message)
                        }), options: [], format: nil) as? [String: Any] ?? [:]
                    } else {
                        mmDict = try PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: mmpath)), options: [], format: nil) as? [String: Any] ?? [:]
                    }
                    
                    // print(mmDict as Any)
                    if mmDict["MCMMetadataIdentifier"] as! String == bundleID {
                        returnedurl = URL(fileURLWithPath: "/var/mobile/Containers/Data/Application").appendingPathComponent(dir)
                    }
                    for i in 0..<appsinfo.count {
                        if appsinfo[i].bundleIdentifier == mmDict["MCMMetadataIdentifier"] as! String {
                            appsinfo[i].dataURL = URL(fileURLWithPath: "/var/mobile/Containers/Data/Application").appendingPathComponent(dir)
                        }
                    }
            
//                    if appsinfo.contains(where: {$0.bundleIdentifier==bundleID}) == false {
////                        appsinfo.append()
//                    }
                
                } else {
                    print("WARNING: Directory \(dir) does not have a metadata plist, skipping.")
                }
            } catch {
                throw ("Could not get data of \(mmpath): \(error.localizedDescription)")
            }
        }
        if returnedurl != URL(string: "none") {
            return returnedurl!
        } else {
            throw "Error getting data directory for app \(bundleID)"
        }
    }
    public static func getAppGroupDir(bundleID: String) throws -> URL {
        let fm = FileManager.default
        var returnedurl = URL(string: "none")
        var dirlist = [""]

        do {
            dirlist = try fm.contentsOfDirectory(atPath: "/var/mobile/Containers/Shared/AppGroup")
            // print(dirlist)
        } catch {
            throw "Could not access /var/mobile/Containers/Shared/AppGroup.\n\(error.localizedDescription)"
        }
        for appinfo in appsinfo {
            if  appinfo.bundleIdentifier == bundleID && (!appinfo.groupURL.path.contains("none")){
                return appinfo.groupURL
            }
        }
        for dir in dirlist {
            // print(dir)
            let mmpath = "/var/mobile/Containers/Shared/AppGroup/" + dir + "/.com.apple.mobile_container_manager.metadata.plist"
            // print(mmpath)
            do {
                var mmDict: [String: Any]
                if fm.fileExists(atPath: mmpath) {
                    if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                        mmDict = try PropertyListSerialization.propertyList(from: try AbsoluteSolver.readFile(path: mmpath, progress: {message in
                           // print(message)
                        }), options: [], format: nil) as? [String: Any] ?? [:]
                    } else {
                        mmDict = try PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: mmpath)), options: [], format: nil) as? [String: Any] ?? [:]
                    }
                    
                   //  print(mmDict as Any)
                 //   print(dir)
//                    if dir == "23273DB2-782D-4E7C-953E-2E2075B6B57A"{
//                         print(mmDict as Any)
//                    }
                    //print(mmDict["MCMMetadataIdentifier"] as! String)
                    if mmDict["MCMMetadataIdentifier"] as! String == ("group."+bundleID) {
                        returnedurl = URL(fileURLWithPath: "/var/mobile/Containers/Shared/AppGroup").appendingPathComponent(dir)

                    }
                    for i in 0..<appsinfo.count {
                        if (("group."+appsinfo[i].bundleIdentifier)) == mmDict["MCMMetadataIdentifier"] as! String {
                            print("set found groupURL")
                            appsinfo[i].groupURL = returnedurl!
                        }
                    }
                    
                    print("init group dir")
                } else {
                    print("WARNING: Directory \(dir) does not have a metadata plist, skipping.")
                }
            } catch {
                throw ("Could not get data of \(mmpath): \(error.localizedDescription)")
            }
        }
        for i in 0..<appsinfo.count {
            if appsinfo[i].groupURL.path.contains("none"){
                appsinfo[i].groupURL=URL(fileURLWithPath: "not_found")
            }
            
        }
    
        return returnedurl!
    }

     static func exportIPA(app: SBApp) throws -> URL {
        // UIApplication.shared.progressAlert(title: "Exporting \(app.name)...")
        do {
            let uuid = UUID().uuidString
            let payloaddir = FileManager.default.temporaryDirectory.appendingPathComponent(uuid).appendingPathComponent("Payload")
            let filename = app.name + "_" + app.version
            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                try? AbsoluteSolver.delete(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid), progress: {message in
                    print(message)
                })
            } else {
                try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid))
            }
            print("rmed file")
            try FileManager.default.createDirectory(at: payloaddir, withIntermediateDirectories: true)
            print("made payload dir \(payloaddir)")
            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                try AbsoluteSolver.copy(at: app.bundleURL, to: payloaddir.appendingPathComponent(app.bundleURL.lastPathComponent), progress: {message in
                    print(message)
                })
            } else {
                try fm.copyItem(at: app.bundleURL, to: payloaddir.appendingPathComponent(app.bundleURL.lastPathComponent))
            }
            var fileList = [payloaddir]
            let metaData = payloaddir.deletingLastPathComponent().appendingPathComponent("iTunesMetadata.plist")
            print("copied \(app.bundleURL) to \(payloaddir.appendingPathComponent(app.bundleURL.lastPathComponent))")
            
            do {
                try AbsoluteSolver.copy(at: app.bundleURL.deletingLastPathComponent().appendingPathComponent("iTunesMetadata.plist"), to: metaData, progress: {message in
                    print(message)
                })
                print("try to copy iTunesMetadata.plist from \(metaData)")
                fileList.append(metaData)
            } catch {
                print("copied iTunesMetadata.plist error")
            }
            
            // try FileManager().zipItem(at: payloaddir, to: FileManager.default.temporaryDirectory.appendingPathComponent(filename).appendingPathExtension("ipa"))
            try Compression.shared.compress(paths: fileList, outputPath: FileManager.default.temporaryDirectory.appendingPathComponent(uuid+"/"+filename).appendingPathExtension("ipa"), format: .zip)
            UIApplication.shared.dismissAlert(animated: false)
            print("zipped \(payloaddir) to \(FileManager.default.temporaryDirectory.appendingPathComponent(uuid+"/"+filename).appendingPathExtension("ipa"))")
            // sleep(UInt32(0.5))
            if !(UserDefaults.standard.bool(forKey: "AbsoluteSolverDisabled")) {
                try? AbsoluteSolver.delete(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid+"/Payload"), progress: {message in
                    print(message)
                })
            } else {
                try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent(uuid+"/Payload"))
            }
            return FileManager.default.temporaryDirectory.appendingPathComponent(uuid+"/"+filename).appendingPathExtension("ipa")
        } catch {
            print("error at the next step")
            Haptic.shared.notify(.error)
            throw "There was an error exporting the ipa.\n\(error.localizedDescription)"
        }
    }
    
    // MARK: - opens apps

    // from stackoverflow
    public static func openApp(bundleID: String) -> Bool {
//        guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return false }
//        let workspace = obj.perform(#selector(LSApplicationWorkspace.default))?.takeUnretainedValue() as? NSObject
//        let open = workspace?.perform(#selector(LSApplicationWorkspace.openApplication(withBundleID:)), with: bundleID) != nil
        return LSApplicationWorkspace.default().openApplication(withBundleID: bundleID)
    }

    static func getApps() throws -> [SBApp] {
        let lsapps = LSApplicationWorkspace.default().allApplications()
        //print("lsapps: \(String(describing: lsapps))")
        
        // TODO: Map LSApplicationProxy to SBApp?
        if (lsapps?.isEmpty) == nil {}
            
        var dotAppDirs: [URL] = []
            
        let systemAppsDir = try fm.contentsOfDirectory(at: systemApplicationsUrl, includingPropertiesForKeys: nil)
        let userAppsDir = try fm.contentsOfDirectory(at: userApplicationsUrl, includingPropertiesForKeys: nil)
            
        for userAppFolder in userAppsDir {
            let userAppFolderContents = try fm.contentsOfDirectory(at: userAppFolder, includingPropertiesForKeys: nil)
            if let dotApp = userAppFolderContents.first(where: { $0.absoluteString.hasSuffix(".app/") }) {
                dotAppDirs.append(dotApp)
            }
        }
            
        dotAppDirs += systemAppsDir
            
        var apps: [SBApp] = []
            
        for bundleUrl in dotAppDirs {
            let infoPlistUrl = bundleUrl.appendingPathComponent("Info.plist")
            if !fm.fileExists(atPath: infoPlistUrl.path) {
                // some system apps don't have it, just ignore it and move on.
                continue
            }
                
            guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String: AnyObject] else { UIApplication.shared.alert(body: "Error opening info.plist for \(bundleUrl.absoluteString)"); throw "Error opening info.plist for \(bundleUrl.absoluteString)" }
            guard let CFBundleIdentifier = infoPlist["CFBundleIdentifier"] as? String else { UIApplication.shared.alert(body: "App \(bundleUrl.absoluteString) doesn't have bundleid"); throw ("App \(bundleUrl.absoluteString) doesn't have bundleid") }
                
            var app = SBApp(bundleIdentifier: CFBundleIdentifier, name: "Unknown", bundleURL: bundleUrl, version: "Unknown", pngIconPaths: [], hiddenFromSpringboard: false)
            var appinfo = Appinfo(bundleIdentifier: CFBundleIdentifier, dataURL: URL(fileURLWithPath: "none"), groupURL: URL(fileURLWithPath: "none"))
            if infoPlist.keys.contains("CFBundleShortVersionString") {
                guard let CFBundleShortVersionString = infoPlist["CFBundleShortVersionString"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw ("Error reading display name for \(bundleUrl.absoluteString)") }
                app.version = CFBundleShortVersionString
            } else if infoPlist.keys.contains("CFBundleVersion") {
                guard let CFBundleVersion = infoPlist["CFBundleVersion"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw ("Error reading display name for \(bundleUrl.absoluteString)") }
                app.version = CFBundleVersion
            }
                
            if infoPlist.keys.contains("CFBundleDisplayName") {
                guard let CFBundleDisplayName = infoPlist["CFBundleDisplayName"] as? String else { UIApplication.shared.alert(body: "Error reading display name for \(bundleUrl.absoluteString)"); throw ("Error reading display name for \(bundleUrl.absoluteString)") }
                if CFBundleDisplayName != "" {
                    app.name = CFBundleDisplayName
                } else {
                    app.name = ((NSURL(fileURLWithPath: bundleUrl.path).deletingPathExtension)?.lastPathComponent)!
                }
            } else if infoPlist.keys.contains("CFBundleName") {
                guard let CFBundleName = infoPlist["CFBundleName"] as? String else { UIApplication.shared.alert(body: "Error reading name for \(bundleUrl.absoluteString)"); throw ("Error reading name for \(bundleUrl.absoluteString)") }
                app.name = CFBundleName
            }
                
            // obtaining png icons inside bundle. defined in info.plist
            if app.bundleIdentifier == "com.apple.mobiletimer" {
                // use correct paths for clock, because it has arrows
                // This looks absolutely horrible, why do we even try
                app.pngIconPaths += ["circle_borderless@2x~iphone.png"]
            }
            if let CFBundleIcons = infoPlist["CFBundleIcons"] {
                if let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as? [String: AnyObject] {
                    if let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                        app.pngIconPaths += CFBundleIconFiles.map { $0 + "@2x.png" }
                    }
                }
            }
            if infoPlist.keys.contains("CFBundleIconFile") {
                // happens in the case of pseudo-installed apps
                if let CFBundleIconFile = infoPlist["CFBundleIconFile"] as? String {
                    app.pngIconPaths.append(CFBundleIconFile + ".png")
                }
            }
            if infoPlist.keys.contains("CFBundleIconFiles") {
                // only seen this happen in the case of Wallet
                if let CFBundleIconFiles = infoPlist["CFBundleIconFiles"] as? [String], !CFBundleIconFiles.isEmpty {
                    app.pngIconPaths += CFBundleIconFiles.map { $0 + ".png" }
                }
            }
                
            apps.append(app)
            appsinfo.append(appinfo)
        }
            
        return apps
    }
}

struct SBApp: Identifiable, Equatable {
    var id = UUID()
    var bundleIdentifier: String
    var name: String
    var bundleURL: URL
    var version: String
    var pngIconPaths: [String]
    var hiddenFromSpringboard: Bool
//    var dataURL: URL
//    var groupURL: URL
}
struct Appinfo: Identifiable, Equatable{
    var id = UUID()
    var bundleIdentifier: String
    var dataURL: URL
    var groupURL: URL
}
