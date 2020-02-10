//Copyright © 2019 Extole. All rights reserved.

import SwiftUI

struct ProfileView: View {
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("First Name")
                TextField("First Name", text: $firstName)
                Text("Last Name")
                TextField("Last Name", text: $lastName)
                Text("Email")
                TextField("Email", text: $email)
                Text("Login").foregroundColor(.blue)
                Spacer()
            }
            .navigationBarTitle(Text("Account"))
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
