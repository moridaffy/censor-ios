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
    
    let window = UIWindow()
    
    // TODO: fix colors for light mode and disable overriding
    window.overrideUserInterfaceStyle = .dark
    
    window.rootViewController = RootViewController().embedInNavigationController()
    window.makeKeyAndVisible()
    window.tintColor = ColorManager.shared.accent
    
    self.window = window
    
    setupThirdParties()
    
    print("🔥 HomeDirectory: \(NSHomeDirectory())")
    
    return true
  }
  
  private func setupThirdParties() {
    GADMobileAds.sharedInstance().start(completionHandler: nil)
  }
  
}

