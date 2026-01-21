import AppKit
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    UNUserNotificationCenter.current().delegate = self

    if let userInfo = notification.userInfo,
      let response = userInfo[NSApplication.launchUserNotificationUserInfoKey]
        as? UNNotificationResponse
    {
      handleNotificationResponse(response)
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
  ) async {
    handleNotificationResponse(response)
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
  ) async -> UNNotificationPresentationOptions {
    [.banner, .sound]
  }

  private func handleNotificationResponse(_ response: UNNotificationResponse) {
    guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else {
      terminateApp()
      return
    }

    let userInfo = response.notification.request.content.userInfo
    let session = userInfo["session"] as? String
    let tabName = userInfo["tabName"] as? String
    let paneId = userInfo["paneId"] as? String

    focusGhostty()

    if let session = session, !session.isEmpty,
      let tabName = tabName, !tabName.isEmpty
    {
      focusZellijTab(session: session, tabName: tabName, paneId: paneId)
    }

    terminateApp()
  }

  private func terminateApp() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      NSApplication.shared.terminate(nil)
    }
  }
}
