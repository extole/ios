//Copyright © 2019 Extole. All rights reserved.

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ShareItem(title: "Virtual California", description: "Roll it")
            ShareItem(title: "Virtual Minesota", description: "Roll it")
            ShareItem(title: "Virtual NY", description: "Roll it")
            ShareItem(title: "Virtual Stefan", description: "Roll it")

            
            Spacer()
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
