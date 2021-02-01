//
//  AppDelegate.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import UIKit
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    IAPManager.shared.startObserving()
    
    setupWindow()
    setupThirdParties()
    
    print("🔥 HomeDirectory: \(NSHomeDirectory())")
    
    return true
  }
  
  private func setupWindow() {
    let window = UIWindow()
    
    // TODO: fix colors for light mode and disable overriding
    window.overrideUserInterfaceStyle = .dark
    
    window.rootViewController = RootViewController().embedInNavigationController()
    window.makeKeyAndVisible()
    window.tintColor = ColorManager.shared.accent
    
    self.window = window
  }
  
  private func setupThirdParties() {
    GADMobileAds.sharedInstance().start(completionHandler: nil)
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    IAPManager.shared.stopObserving()
  }
  
}

