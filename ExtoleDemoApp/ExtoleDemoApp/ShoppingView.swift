//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct ShoppingView: View {

     @ObservedObject var appState: AppState
    
    var body: some View {
        
        let california = ShareItem(title: "Virtual California", description: "Roll it");
        return NavigationView {
            List {
                NavigationLink(destination: california) {
                    california
                }
                ShareItem(title: "Virtual California", description: "Roll it")
                ShareItem(title: "Virtual Minesota", description: "Roll it")
                ShareItem(title: "Virtual NY", description: "Roll it")
                ShareItem(title: "Ca La Mama Acasa", description: "Roll it")
                CallToAction(appState: appState)
                Spacer()
            }
            .navigationBarTitle(Text("Extole Demo"))
        }
    }
}
