//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""

    var body: some View {
        return NavigationView {
            VStack (alignment: .leading) {
                HStack  {
                    Text("First Name")
                    TextField("Joe", text: $firstName)
                }
                HStack {
                    Text("Last Name")
                    TextField("Doe", text: $lastName)
                }
                HStack {
                    Text("Email")
                    TextField("joe@doe.com", text: $email)
                }
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
            .navigationBarTitle(Text("Login"))
            Spacer()
        }
        .onReceive(appState.$shareExperience, perform: { newShare in
           if let existingState = newShare {
                self.firstName = existingState.me.first_name ?? ""
                self.lastName = existingState.me.last_name ?? ""
                self.email = existingState.me.email ?? ""
            }
        })
    }
}
