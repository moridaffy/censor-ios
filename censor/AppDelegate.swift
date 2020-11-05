//
//  AppDelegate.swift
//  censor
//
//  Created by Maxim Skryabin on 20.10.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let window = UIWindow()
    window.rootViewController = RootViewController().embedInNavigationController()
    window.makeKeyAndVisible()
    window.tintColor = ColorManager.shared.accent
    
    // TODO: fix colors for light mode and disable overriding
    window.overrideUserInterfaceStyle = .dark
    
    self.window = window
    
    print("🔥 HomeDirectory: \(NSHomeDirectory())")
    
    return true
  }
  
}

