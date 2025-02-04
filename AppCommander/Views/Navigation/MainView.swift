//
//  MainView.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-02.
//

import SwiftUI

struct MainView: View {
    @State private var searchText = ""
    @State var debugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")

    // MARK: - Literally the worst code ever. Will I fix it? No!
    @State private var showSysApp = false
    @Binding public var allApps: [SBApp]
    @State var apps = [SBApp(bundleIdentifier: "ca.bomberfish.AppCommander.GuruMeditation", name: "Application Error", bundleURL: URL(string: "/")!, version: "0.6.9", pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)]
    var body: some View {
        let binding = Binding {
                    showSysApp
                } set: {
                    print("Show System Application \($0)")
                    showSysApp=$0
                    if !showSysApp {
                        apps = allApps.filter{!$0.bundleIdentifier.starts(with: "com.apple.")  }
                        //print(allApps)
                    }else{
                        apps=allApps
                    }
                }
        NavigationView {
            ZStack {
                //GradientView()
                ScrollView {
                    VStack {
                        VStack(alignment: .leading) {
                            Label("Apps (\(apps.count))", systemImage: "square.grid.2x2")
                                .font(.system(.caption))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                        VStack {
                            VStack {
                                Section {
                                    if apps == [SBApp(bundleIdentifier: "", name: "", bundleURL: URL(string: "/")!, version: "1.0.0", pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)] {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    } else {
                                        ForEach(apps) { app in
                                            // 💀
                                            AppCell(imagePath: app.bundleURL.appendingPathComponent(app.pngIconPaths.first ?? "this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao").path, bundleid: app.bundleIdentifier, name: app.name, large: false, link: true, bundleURL: app.bundleURL, sbapp: app)
                                                .contextMenu {
                                                    Button(action: {
                                                        if ApplicationManager.openApp(bundleID: app.bundleIdentifier) {
                                                            Haptic.shared.notify(.success)
                                                        } else {
                                                            Haptic.shared.notify(.error)
                                                        }
                                                    }, label: {
                                                        Label("Open App", systemImage: "arrow.up.forward.app")
                                                    })
                                                }
                                        }
                                    }
                                }
                                .listRowBackground(Color.clear)
                                
                                .background(.ultraThinMaterial)
                                .cornerRadius(16)
                            }
                            .padding([.horizontal], 8)
                            .padding([.vertical], 5)
                        }
                        .cornerRadius(16)
                        VStack(alignment: .leading) {
                            Text("You've come a long way, traveler. Have a :lungs:.\n🫁")
                                .font(.system(.caption))
                                .multilineTextAlignment(.center )
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                    }
                }
                // .background(GradientView())
                .listRowBackground(Color.clear)
                .listStyle(InsetGroupedListStyle())
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .navigationTitle("AppCommander")
                .onChange(of: searchText) { searchText in
                    
                    if !searchText.isEmpty {
                        apps = apps.filter { $0.name.localizedCaseInsensitiveContains(searchText)
                            
                        }
                    } else {
                        if !showSysApp {
                            apps = allApps.filter{!$0.bundleIdentifier.starts(with: "com.apple.")  }
                            //print(allApps)
                        }else{
                            apps=allApps
                        }
                    }
                }
                .toolbar {
                    HStack {
                        Menu(content: {
                            Section {
                                Button(action: {
                                    apps = allApps
                                }, label: {
                                    Label("None", systemImage: "list.bullet")
                                })
                                Toggle("Show System Applications", isOn: binding)
                                Menu("Alphabetical") {
                                    Button(action: {
                                        apps = apps.sorted { $0.name < $1.name }
                                    }, label: {
                                        Label("Case-sensitive", systemImage: "character")
                                    })
                                    
                                    Button(action: {
                                        apps = apps.sorted { $0.name.lowercased() < $1.name.lowercased() }
                                    }, label: {
                                        Label("Case-insensitive", systemImage: "textformat")
                                    })
                                }
                            } header: {
                                Text("Sort Apps")
                            }
                            
                        }, label: {
                            Label("Sort", systemImage: "line.3.horizontal.decrease.circle")
                                .foregroundColor(Color(UIColor.label))
                        })
                        .foregroundColor(Color(UIColor.label))
                    }
                }
                .onAppear {
                    //apps = allApps
                    if !showSysApp {
                        apps = allApps.filter{!$0.bundleIdentifier.starts(with: "com.apple.")  }
                        //print(allApps)
                    }else{
                        apps=allApps
                    }
                }
                //            .onAppear {
                // #if targetEnvironment(simulator)
                //            #else
                //            isUnsandboxed = MDC.unsandbox()
                //            if !isUnsandboxed {
                //                isUnsandboxed = MDC.unsandbox()
                //            } else {
                //                allApps = try! ApplicationManager.getApps()
                //                apps = allApps
                //            }
                //            #endif
                //        }
                
                .refreshable {
#if targetEnvironment(simulator)
#else
                    //                if !isUnsandboxed {
                    //                    isUnsandboxed = MDC.unsandbox()
                    //                } else {
                    print("refresh")
                    do {
                        allApps = try ApplicationManager.getApps()
                    } catch {
                        apps = [SBApp(bundleIdentifier: "ca.bomberfish.AppCommander.GuruMeditation", name: "Application Error", bundleURL: URL(string: "/")!, version: "0.6.9", pngIconPaths: ["this-app-does-not-have-an-icon-i-mean-how-could-anything-have-this-string-lmao"], hiddenFromSpringboard: false)]
                        UIApplication.shared.alert(title: "WARNING", body: "AppCommander was unable to get installed apps. Press OK to continue in a feature-limited mode.")
                    }
                    apps = allApps
                    //                }
#endif
                }.navigationViewStyle(StackNavigationViewStyle())
                //.listStyle(.sidebar)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

// struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView(isUnsandboxed: true)
//    }
// }
