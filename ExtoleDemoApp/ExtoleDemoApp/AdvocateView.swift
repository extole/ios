//Copyright © 2019 Extole. All rights reserved.

import SwiftUI

struct AdvocateView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        let shareLink = Text(appState.shareExperience?.calls_to_action.account_page ?? "Share")
        
        return NavigationView {
            VStack {
                Text(appState.shareExperience?.me.email ?? "")
                
                NavigationLink(destination: ShareView(appState: appState)) {
                    shareLink
                }
            
                Text("Logout")
                    .foregroundColor(.blue).onTapGesture {
                        self.appState.program.sessionManager.logout()
                }
                Spacer()
                .navigationBarTitle("Account")
            }
        }
    }
}
