import SwiftUI

@main
struct iOSDemoApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ExtoleCampaign(delegate.extole))
        }
    }
}
