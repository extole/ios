//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct HomeTabs: View {
    
    @EnvironmentObject var appState: AppState
    @State var selected = 0
    
    func ctaLink() -> String {
        return self.appState.shareExperience?.program_label ?? ""
    }
    
    var body: some View {
        return TabView(selection: $selected) {
            ShoppingView()
                  .tabItem {
                      Image(systemName: "1.circle")
                      Text("Shopping")
                  }.tag(0)
              ProfileView()
                  .tabItem {
                      Image(systemName: "2.circle")
                      Text("Profile")
                  }.tag(1)

        }
    }
}
