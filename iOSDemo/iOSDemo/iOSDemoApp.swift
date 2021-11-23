import SwiftUI

@main
struct iOSDemoApp: App {
    let extole = ExtoleCampaign()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(extole)
        }
    }
}
