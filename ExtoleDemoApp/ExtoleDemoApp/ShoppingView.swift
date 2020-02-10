//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct ShoppingView: View {

    @State var ctaText: String = "CTA"
    
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
                CallToAction(title: $ctaText)
                Spacer()
            }
            .navigationBarTitle(Text("Extole Demo"))
        }.onAppear {
            let extole = Extole.init(programDomain: "ios-santa.extole.io")
            let program = extole.session().program(labels: "refer-a-friend")
            program.ready { shareExperience in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.ctaText = shareExperience.sharing.facebook.title ?? "default"
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingView()
    }
}
