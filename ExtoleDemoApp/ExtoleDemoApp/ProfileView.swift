//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct ProfileView: View {
    @ObservedObject var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }

    var body: some View {
        if appState.isLogged {
            return AnyView(AdvocateView(appState: appState))
        } else {
            return AnyView(LoginView(appState: appState))
        }
    }
}
