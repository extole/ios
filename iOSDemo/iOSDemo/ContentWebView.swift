import SwiftUI

struct ContentWebView: View {
    @EnvironmentObject var extoleProgram: ExtoleCampaign
    var body: some View {
        VStack {
            extoleProgram.getWebView(zoneName: "microsite")
        }
    }
}

struct ContentWebView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ExtoleCampaign())
    }
}
