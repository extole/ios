import SwiftUI
import ExtoleMobileSDK

struct ContentView: View {
    @EnvironmentObject var extoleCampaign: ExtoleCampaign
    var body: some View {
        NavigationView {
            VStack {
                AsyncImage(url: URL(string: extoleCampaign.cta.image))
                    .frame(height: 400)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                    .shadow(radius: 7)
                Button(extoleCampaign.cta.text) {
                        extoleCampaign.extole.sendEvent(extoleCampaign.cta.touchEvent, [:], completion: { (idEvent, error) in
                        })
                    }.padding()
                Spacer()
            }.task {
                extoleCampaign.fetch()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
