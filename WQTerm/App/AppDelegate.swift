import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Auto-mount sandbox containers on launch (M2)
        SandboxMounter.shared.autoMountAllContainers()
        // Start audit logging (M6)
        AuditLogger.shared.log(event: .appLaunch)
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        IOSCompatibility.shared.recheckOnForeground()
    }
}
