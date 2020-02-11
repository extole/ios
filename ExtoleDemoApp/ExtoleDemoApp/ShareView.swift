//Copyright © 2019 Extole. All rights reserved.

import SwiftUI


struct ShareView: View {
    @ObservedObject var appState: AppState

    @State var showingAlert: Bool = false
    
    @State private var showShareSheet = false
    
    enum SheetAction {
        case share
        case terms
    }
    
    @State private var sheetActon: SheetAction = .share
    
    @State private var showSafari = false
    
    func copy() {
        UIPasteboard.general.string = self.appState.shareExperience?.me.shareable_link
        showingAlert = true
        appState.shared(channel: UIActivity.ActivityType.copyToPasteboard.rawValue)
    }
    
    func sheetView() -> some View {
        switch sheetActon {
        case .share : return AnyView(ShareSheet(activityItems: [self.shareableLink], callback: self.shared))
        case .terms: return AnyView(SafariView(url:URL(string: self.termsLink)!))
        }
    }
    
    func share() {
        self.sheetActon = .share
        self.showShareSheet = true
        
    }
    
    var shareableLink: String {
        get {
            return appState.shareExperience?.me.shareable_link ?? "Shareable Link";
        }
    }
    
    var termsLink: String {
        get {
            return appState.shareExperience?.links.terms_url ?? "Terms Url"
        }
    }
    
    var poweredLink: String {
        get {
            return appState.shareExperience?.links.company_url ?? "Powered By"
        }
    }
    
    func shared(_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) {
        appState.shared(channel: activityType?.rawValue ?? "custom")
    }
    
    var body: some View {
        VStack {
            Text(appState.shareExperience?.calls_to_action.menu ?? "Title")
            Text(appState.shareExperience?.links.how_it_works_url ?? "How It Works")
            Button(shareableLink, action: copy)
            Button("Share", action: share)
            Spacer()
            Button(termsLink, action: {
                self.sheetActon = .terms
                self.showShareSheet = true
            })
            Button(poweredLink, action: {
                UIApplication.shared.open(URL(string: self.poweredLink)!)
            })
            
        }
        .toast(isShowing: $showingAlert, text: Text("Copied"))
        .sheet(isPresented: $showShareSheet) {
            self.sheetView()
        }
    }
}
