//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.isLogged {
            return AnyView(AdvocateView())
        } else {
            return AnyView(LoginView())
        }
    }
}
