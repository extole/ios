//Copyright © 2019 Extole. All rights reserved.

import SwiftUI


struct ShareView: View {
    @ObservedObject var appState: AppState

    @State var showingAlert: Bool = false
    
    func copy() {
        UIPasteboard.general.string = self.appState.shareExperience?.me.shareable_link
        showingAlert = true
    }
    
    var body: some View {
        VStack {
            Text(appState.shareExperience?.calls_to_action.menu ?? "Title")
            Text(appState.shareExperience?.links.how_it_works_url ?? "How It Works")
            Text(appState.shareExperience?.me.shareable_link ?? "Shareable Link")
            Button("Share", action: copy)
            Spacer()
            Text(appState.shareExperience?.links.terms_url ?? "Terms Url")
            Text(appState.shareExperience?.links.company_url ?? "Powered By")
            
        }
        .toast(isShowing: $showingAlert, text: Text("Copied"))
    }
}
