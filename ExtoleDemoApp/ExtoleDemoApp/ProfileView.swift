//Copyright © 2019 Extole. All rights reserved.

import SwiftUI

struct ProfileView: View {
    @ObservedObject var appState: AppState
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""

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
                                            },
                                              error: { e in
                                            })
                    }
                }
                Spacer()
            }
            .navigationBarTitle(Text("Account"))
        }.onAppear{
            if let existingState = self.appState.shareExperience {
                self.firstName = existingState.me.first_name ?? ""
                self.lastName = existingState.me.last_name ?? ""
                self.email = existingState.me.email ?? ""
            }
        }
    }
}
