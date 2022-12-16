import SwiftUI
import ExtoleMobileSDK

struct ContentView: View {
    let extoleWrapper: ExtoleSDK = ExtoleSDK()
    @State var zone: Zone? = nil
    var body: some View {
        NavigationView {
            VStack {
                AsyncImage(url: URL(string: zone?.get("image") as! String? ?? ""))
                    .frame(height: 400)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                    .shadow(radius: 7)
                Button(zone?.get("title") as! String? ?? "") {
                    extoleWrapper.sendEvent("mobile_cta_touch", [:])
                    }.padding()
                Spacer()
            }.task {
                extoleWrapper.setup()
                extoleWrapper.extole.fetchZone("mobile_cta", [:]) { zone, campaign, error in
                    self.zone = zone
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
