//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct CallToAction: View {
    @EnvironmentObject var appState: AppState

    @State var ctaLink: String = "Loading..."

    var shareDestination: some View {
        get {
            if appState.isLogged {
                return AnyView(ShareView())
            } else {
                return AnyView(LoginView())
            }
        }
    }

    var body: some View {
        NavigationLink(destination: shareDestination) {
            Text($ctaLink.animation().wrappedValue).font(.callout).foregroundColor(.blue)
        }.onAppear( perform: {
            //self.ctaLink = self.appState.shareExperience?.program_label ?? "Loading";
        }).onReceive(appState.$shareExperience, perform: { newShare in
            self.ctaLink = newShare?.program_label ?? "Loading";
        })
    }
}
