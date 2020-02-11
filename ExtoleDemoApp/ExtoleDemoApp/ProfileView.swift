//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct ProfileView: View {
    @ObservedObject var appState: AppState
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    
    init(appState: AppState) {
        self.appState = appState
        importState(shareExperience : appState.shareExperience)
    }

    func importState(shareExperience: ExtoleApp.AdvocateMobileExperience?) {
        if let existingState = shareExperience {
            self.firstName = existingState.me.first_name ?? ""
            self.lastName = existingState.me.last_name ?? ""
            self.email = existingState.me.email ?? ""
        }
    }
    
    var body: some View {
        return NavigationView {
            VStack {
                Text("First Name")
                TextField("First Name", text: $firstName)
                Text("Last Name")
                TextField("Last Name", text: $lastName)
                Text("Email")
                TextField("Email", text: $email)
                Text("Login").foregroundColor(.blue).onTapGesture {
                    self.appState.program.sessionManager.async { session in
                        session.updateProfile(email: self.email,
                                              first_name: self.firstName,
                                              last_name: self.lastName,
                                              success:  {
                                                self.appState.reset()
                                                self.appState.refresh()
                                            },
                                              error: { e in
                                            })
                    }
                }
                Spacer()
            }
            .navigationBarTitle(Text("Account"))
        }
        .onReceive(appState.$shareExperience, perform: { newShare in
            self.importState(shareExperience: newShare)
        })
    }
}
