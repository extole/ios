import Foundation

public class CTA {
    var text: String
    var image: String
    var touchEvent: String
    
    init(text: String = "", image: String = "Loading...", touchEvent: String = "") {
        self.text = text
        self.image = image
        self.touchEvent = touchEvent
    }
}
