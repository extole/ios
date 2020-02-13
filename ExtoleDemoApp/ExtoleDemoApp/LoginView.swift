//Copyright © 2019 Extole. All rights reserved.

import SwiftUI
import ExtoleApp

struct LoginFields {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
}

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @State var fields = LoginFields()

    var body: some View {
        return NavigationView {
            VStack {
                HStack  {
                    Text("First Name")
                    TextField("Joe", text: self.$fields.firstName)
                }
                HStack {
                    Text("Last Name")
                    TextField("Doe", text: self.$fields.lastName)
                }
                HStack {
                    Text("Email")
                    TextField("joe@doe.com", text: self.$fields.email)
                }
                Text("Login").foregroundColor(.blue).onTapGesture {
                    self.appState.program.sessionManager.async { session in
                        session.updateProfile(email: self.fields.email,
                                              first_name: self.fields.firstName,
                                              last_name: self.fields.lastName,
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
        }.onAppear( perform: {
            _ = self.appState.$shareExperience.map { shareExperience in
                LoginFields(firstName: shareExperience?.me.first_name ?? "",
                            lastName: shareExperience?.me.last_name ?? "",
                            email: shareExperience?.me.email ?? "")
                
            }
            .assign(to: \.fields, on: self)
        })
    }
}
