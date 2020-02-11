//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct CallToAction: View {
    @ObservedObject var appState: AppState

    var ctaLink: String {
        return appState.shareExperience?.program_label ?? "Loading..."
    }

    var shareDestination: some View {
        get {
            if appState.isLogged {
                return AnyView(ShareView(appState: appState))
            } else {
                return AnyView(LoginView(appState: appState))
            }
        }
    }

    var body: some View {
        NavigationLink(destination: shareDestination) {
            Text(ctaLink).font(.callout).foregroundColor(.blue)
        }
    }
}
