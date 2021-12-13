import SwiftUI

struct ContentView: View {
    @EnvironmentObject var extoleProgram: ExtoleCampaign
    @State private var email: String = ""
    var body: some View {
        NavigationView {
            VStack {
                AsyncImage(url: URL(string: extoleProgram.shareExperience.shareImage))
                    .frame(height: 400)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                    .shadow(radius: 7)
                Text(extoleProgram.shareExperience.shareMessage)
                    .padding()
                TextField("Enter your email address", text: $email)
                    .onSubmit {
                        NSLog("Identifying user")
                        extoleProgram.identify(email: email)
                    }.padding()
                NavigationLink(destination: ContentWebView().environmentObject(extoleProgram)) {
                    Text(extoleProgram.shareExperience.shareButtonText)
                }.padding()
                Spacer()
            }.task {
                extoleProgram.fetchExtoleProgram()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
