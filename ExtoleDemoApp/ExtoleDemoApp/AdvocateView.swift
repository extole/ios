//Copyright © 2019 Extole. All rights reserved.

import SwiftUI

struct AdvocateView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        let shareLink = Text(appState.shareExperience?.calls_to_action.account_page ?? "Share")
        
        return NavigationView {
            VStack {
                Text(appState.shareExperience?.me.email ?? "")

                NavigationLink(destination: ShareView()) {
                    shareLink
                }
                Spacer()
                Text("Logout")
                    .foregroundColor(.blue).onTapGesture {
                        self.appState.program.sessionManager.logout()
                }
                .navigationBarTitle("Account")
            }
        }
    }
}
