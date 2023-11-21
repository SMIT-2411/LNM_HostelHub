//
//  LNM_HostelHubApp.swift
//  LNM_HostelHub
//
//  Created by Smit Patel on 06/11/23.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
    
    @available(iOS 9.0,*)
    func application(_ application: UIApplication,open url: URL , options:[UIApplication.OpenURLOptionsKey:Any] = [:])->Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}


@main
struct LNM_HostelHubApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
