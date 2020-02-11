//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct CallToAction: View {
    @ObservedObject var appExperience: AppState

    var ctaLink: String {
        return appExperience.shareExperience?.program_label ?? "Default"
    }

    var body: some View {
        HStack {
            Spacer()
            Text(ctaLink).font(.callout).foregroundColor(.blue)
            Spacer()
        }
    }
}
