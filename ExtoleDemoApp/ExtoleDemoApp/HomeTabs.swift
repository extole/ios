//Copyright © 2019 Extole. All rights reserved.

import SwiftUI

struct HomeTabs: View {
    var body: some View {
        TabView {
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

struct HomeTabs_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabs()
    }
}
