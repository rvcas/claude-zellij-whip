import AppKit

func focusGhostty() {
  let ghostty = NSWorkspace.shared.runningApplications
    .first { $0.bundleIdentifier == "com.mitchellh.ghostty" }
  ghostty?.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
}

func focusZellijTab(session: String, tabName: String, paneId: String?) {
  guard let zellijPath = findZellijPath() else { return }

  let process = Process()
  process.executableURL = URL(fileURLWithPath: zellijPath)
  process.arguments = ["--session", session, "action", "go-to-tab-name", tabName]
  process.standardOutput = FileHandle.nullDevice
  process.standardError = FileHandle.nullDevice

  do {
    try process.run()
    process.waitUntilExit()
  } catch {
    return
  }

  if let paneId = paneId, !paneId.isEmpty {
    focusZellijPane(session: session, paneId: paneId)
  }
}

private func focusZellijPane(session: String, paneId: String) {
  guard let zellijPath = findZellijPath() else { return }

  let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
  let pluginPath = "file:\(homeDir)/.config/zellij/plugins/room.wasm"

  let process = Process()
  process.executableURL = URL(fileURLWithPath: zellijPath)
  process.arguments = [
    "--session", session,
    "pipe",
    "--plugin", pluginPath,
    "--name", "focus-pane",
    "--", paneId,
  ]
  process.standardOutput = FileHandle.nullDevice
  process.standardError = FileHandle.nullDevice

  try? process.run()
  process.waitUntilExit()
}
