//
//  NSNotification.Name+CustomNotifications.swift
//  censor
//
//  Created by Maxim Skryabin on 02.11.2020.
//

import Foundation

extension NSNotification.Name {
  
  private static let notificationPrefix: String = (Bundle.main.bundleIdentifier ?? "ru.mskr.censor") + "."
  
  static let soundPlayerFinishedPlaying = NSNotification.Name(notificationPrefix + "sound_player_finished_playing")
}