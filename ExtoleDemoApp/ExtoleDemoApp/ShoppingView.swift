//Copyright © 2019 Extole. All rights reserved.

import SwiftUI

struct ShoppingView: View {
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
                ShareItem(title: "Virtual Stefan", description: "Roll it")
                CallToAction(title: "Get $40")
                Spacer()
            }
            .navigationBarTitle(Text("Extole Demo"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingView()
    }
}
