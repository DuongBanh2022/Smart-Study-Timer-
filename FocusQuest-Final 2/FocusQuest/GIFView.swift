import SwiftUI
import AppKit

struct GIFView: NSViewRepresentable {
    
    let gifName: String
    
    func makeNSView(context: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        return imageView
    }
    
    func updateNSView(_ imageView: NSImageView, context: Context) {
        if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
            let url = URL(fileURLWithPath: path)
            imageView.image = NSImage(contentsOf: url)
        }
    }
}
