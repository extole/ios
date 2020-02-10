//Copyright © 2019 Extole. All rights reserved.

import SwiftUI

struct CallToAction: View {
    let title: String
    var body: some View {
        HStack {
            Spacer()
            Text(title).font(.callout).foregroundColor(.blue)
            Spacer()
        }
    }
}

struct CallToAction_Previews: PreviewProvider {
    static var previews: some View {
        CallToAction(title: "Get $40")
    }
}
