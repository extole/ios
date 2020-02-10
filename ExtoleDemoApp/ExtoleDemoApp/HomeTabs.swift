//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct HomeTabs: View {
    
    @ObservedObject var appExperience: AppState
    
    func ctaLink() -> String {
        return self.appExperience.shareExperience?.program_label ?? ""
    }
    
    var body: some View {
        return TabView {
            ShoppingView(appExperience: appExperience)
                  .tabItem {
                      Image(systemName: "1.circle")
                      Text("Shopping")
                  }.tag(0)
              ProfileView(appState: appExperience)
                  .tabItem {
                      Image(systemName: "2.circle")
                      Text("Profile")
                  }.tag(1)
          }
    }
}
