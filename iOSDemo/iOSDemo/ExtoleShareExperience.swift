import Foundation

public class ExtoleShareExperience {
    var title: String
    var shareButtonText: String
    var shareMessage: String
    var shareImage: String
    
    init(_ shareExperience: ExtoleShareExperience) {
        self.title = shareExperience.title
        self.shareButtonText = shareExperience.shareButtonText
        self.shareMessage = shareExperience.shareMessage
        self.shareImage = shareExperience.shareImage
    }
    
    init(title: String = "", shareButtonText: String = "Loading...", shareMessage: String = "Loading...",
         shareImage: String = "") {
        self.title = title
        self.shareButtonText = shareButtonText
        self.shareMessage = shareMessage
        self.shareImage = shareImage
    }
}
