import Foundation
import UserNotifications

func sendNotification(args: [String]) async {
  let message = parseArg(args, flag: "--message") ?? "Notification"
  let baseTitle = parseArg(args, flag: "--title") ?? "Claude Code"

  let folder = parseArg(args, flag: "--folder")
  let title = folder != nil ? "\(baseTitle) [\(folder!)]" : baseTitle

  let session = ProcessInfo.processInfo.environment["ZELLIJ_SESSION_NAME"]
  let paneId = ProcessInfo.processInfo.environment["ZELLIJ_PANE_ID"]
  let tabName = getCurrentTabName(session: session)

  let center = UNUserNotificationCenter.current()
  let settings = await center.notificationSettings()

  if settings.authorizationStatus == .notDetermined {
    do {
      let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
      guard granted else { return }
    } catch {
      return
    }
  } else if settings.authorizationStatus == .denied {
    print(
      "Notifications are denied. Please enable in System Settings > Notifications > ClaudeZellijWhip"
    )
    return
  }

  let content = UNMutableNotificationContent()
  content.title = title
  content.body = message
  content.sound = .default
  content.userInfo = [
    "session": session ?? "",
    "tabName": tabName ?? "",
    "paneId": paneId ?? "",
  ]

  let request = UNNotificationRequest(
    identifier: UUID().uuidString,
    content: content,
    trigger: nil
  )

  do {
    try await center.add(request)
  } catch {
    print("Failed to send notification: \(error)")
  }
}

func parseArg(_ args: [String], flag: String) -> String? {
  guard let index = args.firstIndex(of: flag),
    index + 1 < args.count
  else {
    return nil
  }
  return args[index + 1]
}
