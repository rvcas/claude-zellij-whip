import Foundation

private let zellijPaths = [
  "/opt/homebrew/bin/zellij",
  "/usr/local/bin/zellij",
  "/usr/bin/zellij",
]

func findZellijPath() -> String? {
  zellijPaths.first { FileManager.default.fileExists(atPath: $0) }
}

func getCurrentTabName(session: String?) -> String? {
  guard let session = session, !session.isEmpty else { return nil }
  guard let zellijPath = findZellijPath() else { return nil }

  let process = Process()
  process.executableURL = URL(fileURLWithPath: zellijPath)
  process.arguments = ["--session", session, "action", "dump-layout"]

  let pipe = Pipe()
  process.standardOutput = pipe
  process.standardError = FileHandle.nullDevice

  do {
    try process.run()
    process.waitUntilExit()
  } catch {
    return nil
  }

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  guard let layout = String(data: data, encoding: .utf8) else { return nil }

  // Match: tab name="X" ... focus=true
  let pattern = #"tab name="([^"]+)"[^>]*focus=true"#

  guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
    let match = regex.firstMatch(
      in: layout, options: [], range: NSRange(layout.startIndex..., in: layout)),
    let range = Range(match.range(at: 1), in: layout)
  else {
    return nil
  }

  return String(layout[range])
}
