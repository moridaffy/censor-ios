//
//  LocalizeSystem.swift
//  censor
//
//  Created by Maxim Skryabin on 28.01.2021.
//

import Foundation

class LocalizeSystem {
  
  static let shared = LocalizeSystem()
  
  func root(_ root: Root) -> String {
    return root.rawValue.localized()
  }
  
  func projects(_ projects: Projects) -> String {
    return projects.rawValue.localized()
  }
  
  func editor(_ editor: Editor) -> String {
    return editor.rawValue.localized()
  }
  
  func settings(_ settings: Settings) -> String {
    return settings.rawValue.localized()
  }
  
  func common(_ common: Common) -> String {
    return common.rawValue.localized()
  }
  
  func hint(_ hint: Hint) -> String {
    return hint.rawValue.localized()
  }
  
  func error(_ error: Error) -> String {
    return error.rawValue.localized()
  }
}

extension LocalizeSystem {
  enum Root: String {
    case welcomeTitle = "root.welcome.title"
    case welcomeDescription = "root.welcome.description"
    case createButton = "root.button.create"
    case browseButton = "root.button.browse"
  }
  
  enum Projects: String {
    case title = "projects.title"
    case project = "projects.project"
    case newProject = "projects.new_project"
    case newProjectName = "projects.new_project_name"
  }
  
  enum Editor: String {
    case export = "editor.export"
    case selectAudioMode = "editor.select.audio_mode"
    case selectSound = "editor.select.sound"
    case videoRendered = "editor.render.done"
    case soundModeMuteTitle = "editor.sound_mode.mute.title"
    case soundModeMuteDescription = "editor.sound_mode.mute.description"
    case soundModeSilenceTitle = "editor.sound_mode.silence.title"
    case soundModeSilenceDescription = "editor.sound_mode.silence.description"
    case soundModeOriginalTitle = "editor.sound_mode.original.title"
    case soundModeOriginalDescription = "editor.sound_mode.original.description"
  }
  
  enum Settings: String {
    case title = "settings.title"
    case iconTitle = "settings.icon.title"
    case tipTitle = "settings.tip.title"
    case tipDescription = "settings.tip.description"
    case tipSmallTitle = "settings.tip.small.title"
    case tipMediumTitle = "settings.tip.medium.title"
    case tipLargeTitle = "settings.tip.large.title"
    case purchaseRestoreButton = "settings.iap.purchase_restore_button"
    case purchaseRestored = "settings.iap.purchase_restored"
    case purchaseCompletedTitle = "settings.iap.purchase_completed_title"
    case purchaseCompletedDescription = "settings.iap.purchase_completed_description"
    case premiumAlreadyUnlocked = "settings.debug.already_unlocked"
    case premiumUnlocked = "settings.debug.unlocked"
    case premiumUnlockButton = "settings.debug.unlock_button"
    case premiumAlreadyLocked = "settings.debug.already_locked"
    case premiumLocked = "settings.debug.locked"
    case premiumLockButton = "settings.debug.lock_button"
    case projectsDeleted = "settings.debug.projects_deleted"
    case projectsDeleteButton = "settings.debug.projects_delete_button"
  }
  
  enum Common: String {
    case ok = "common.ok"
    case done = "common.done"
    case cancel = "common.cancel"
    case save = "common.save"
    case create = "common.create"
    case delete = "common.delete"
    case search = "common.search"
  }
  
  enum Hint: String {
    case editorPreview = "hint.editor.preview"
    case editorAddSound = "hint.editor.add_sound"
    case editorTimeline = "hint.editor.timeline"
    case editorAddedSound = "hint.editor.added_sound"
    case editorPlayPause = "hint.editor.play_pause"
    case editorAudioMode = "hint.editor.audio_mode"
    case editorAllSounds = "hint.editor.all_sounds"
    case editorExport = "hint.editor.export"
    case editorHelp = "hint.editor.help"
  }
  
  enum Error: String {
    case error = "error.error"
    case unknownErrorOccured = "error.unknown_error_occured"
    case emptyFileUrl = "error.empty_file_url"
    case cantPlayVideo = "error.unable_to_play_video"
    case cantRenderVideo = "error.unable_to_render_video"
    case cantRestorePurchase = "error.unable_to_restore_purchase"
    case cantPurchase = "error.unable_to_make_purchase"
    case cantConnectToAppStore = "error.unable_to_connect_to_app_store"
    case cantVerifyPurchase = "error.unable_to_verify_purchase"
    case iapNotAllowed = "error.iap_not_allowed"
    case iapCancelled = "error.iap_cancelled"
  }
}

extension LocalizeSystem {
  enum Language: String {
    case english
    case russian
    
    var title: String {
      return "language_\(rawValue)".localized(self.languageCode)
    }
    
    var languageCode: String {
      switch self {
      case .english:
        return "en_US"
      case .russian:
        return "ru_RU"
      }
    }
  }
}

// https://stackoverflow.com/questions/29985614/how-can-i-change-locale-programmatically-with-swift
private extension String {
  func localized(_ languageCode: String? = nil) -> String {
    if let path = Bundle.main.path(forResource: languageCode ?? SettingsManager.shared.languageCode, ofType: "lproj"),
       let bundle = Bundle(path: path) {
      return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    } else {
      return NSLocalizedString(self, comment: "")
    }
  }
}
