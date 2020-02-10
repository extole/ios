//Copyright © 2019 Extole. All rights reserved.

import SwiftUI

struct ProfileView: View {
    @ObservedObject var appState: AppState
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var emailName: String = ""

    var body: some View {
        return NavigationView {
            VStack {
                Text("First Name")
                TextField("First Name", text: $firstName)
                Text("Last Name")
                TextField("Last Name", text: $lastName)
                Text("Email")
                TextField("Email", text: $emailName)
                Text("Login").foregroundColor(.blue).onTapGesture {
                    appState.program.sessionManager.logout()
                    print("trigger login", self.emailName)
                }
                Spacer()
            }
            .navigationBarTitle(Text("Account"))
        }.onAppear{
            if let existingState = self.appState.shareExperience {
                self.firstName = existingState.me.first_name ?? ""
                self.lastName = existingState.me.last_name ?? ""
                self.emailName = existingState.me.email ?? ""
            }
        }
    }
}
