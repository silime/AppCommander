//
//  SettingsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-18.
//

import SwiftUI

struct SettingsView: View {
    @State var consoleEnabled: Bool = UserDefaults.standard.bool(forKey: "LCEnabled")
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")
    @State var analyticsLevel: Int = UserDefaults.standard.integer(forKey: "analyticsLevel")
    // found the funny!
    @State var sex: Bool = UserDefaults.standard.bool(forKey: "sex")
    var body: some View {
        List {
            Section {
                Picker(selection: $analyticsLevel) {
                    Text("None (Disabled)").tag(0)
                    Text("Limited").tag(1)
                    Text("Full").tag(2)
                } label: {
                    Label("Analytics Level", systemImage: "chart.bar.xaxis")
                }
                .onChange(of: analyticsLevel) { new in
                    UserDefaults.standard.set(new, forKey: "analyticsLevel")
                    print(analyticsLevel)
                }
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("Privacy Policy", systemImage: "person.badge.shield.checkmark")
                }
            } header: {
                Label("Analytics", systemImage: "chart.bar")
            }
            Section {
                Toggle(isOn: $debugEnabled, label:{Label("Debug Mode", systemImage: "ladybug")})
                    .toggleStyle(.switch)
                    .tint(.accentColor)
                    .onChange(of: debugEnabled) { new in
                        // set the user defaults
                        UserDefaults.standard.set(new, forKey: "DebugEnabled")
                    }
            }
            if debugEnabled {
                Section {
                    Toggle(isOn: $consoleEnabled, label:{Label("Enable in-app console", systemImage: "terminal")})
                        .toggleStyle(.switch)
                        .tint(.accentColor)
                        .onChange(of: consoleEnabled) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "LCEnabled")
                            if new {
                                consoleManager.isVisible = true
                            } else {
                                consoleManager.isVisible = false
                            }
                        }
                    Toggle(isOn: $sex, label:{Text("😏      Sex")})
                        .tint(.accentColor)
                        .onChange(of: sex) { new in
                            // set the user defaults
                            UserDefaults.standard.set(new, forKey: "sex")
                        }
                } header: {
                    Label("Debug", systemImage: "ladybug")
                }
            }
            if sex {
                Section {
                    Button( action: {
                        // create and configure alert controller
                        let alert = UIAlertController(title: "", message: "This will completely wipe your device", preferredStyle: .actionSheet)
                        
                        // create the actions
                            let newAction = UIAlertAction(title: "Brick Device", style: .default) { (action) in
                                print("sussy!")
                                epochBrick()
                            }
                            alert.addAction(newAction)
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                            // cancels the action
                        }
                        
                        // add the actions
                        alert.addAction(cancelAction)
                        
                        let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
                        // present popover for iPads
                        alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
                        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
                        
                        // present the alert
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                    },label:{
                        Text("Brick Device")
                        
                    })
                } header: {
                    Text("Wipe your device before returning to the person collecting hardware")
                }
            }
            Section(header: Label("AppCommander \(appVersion)\nMade with ❤️ by BomberFish", systemImage: "info.circle").textCase(.none)){}
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
