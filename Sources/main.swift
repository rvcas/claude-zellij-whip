import AppKit

let app = NSApplication.shared
let args = CommandLine.arguments

if args.count > 1 && args[1] == "notify" {
  Task {
    await sendNotification(args: Array(args.dropFirst(2)))
    try? await Task.sleep(for: .milliseconds(500))
    await MainActor.run { app.terminate(nil) }
  }
  app.run()
} else {
  let delegate = AppDelegate()
  app.delegate = delegate
  app.run()
}
