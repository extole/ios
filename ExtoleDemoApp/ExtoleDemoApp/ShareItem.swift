//Copyright © 2019 Extole. All rights reserved.

import SwiftUI

struct ShareItem: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(decorative: "Logo")
            Spacer()
            VStack {
            Text(title).font(.title)
            Text(description).font(.body)
            }
        }
    }
}

struct ShareItem_Previews: PreviewProvider {
    static var previews: some View {
        ShareItem(title: "Virtual Califorornia Roll",
        description: "64 bit roll")
    }
}
