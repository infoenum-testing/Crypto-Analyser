//
//  SafariWrapperViewController.swift
//  Crypto Analyser
//
//  Created by IE15 on 28/01/25.
//

import Foundation
import SwiftUI
import SafariServices

// Custom UIViewController with a Done button
class SafariWrapperViewController: UIViewController {
    private let safariViewController: SFSafariViewController
    private let onDone: () -> Void
    
    init(urlString: String, onDone: @escaping () -> Void) {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        self.safariViewController = SFSafariViewController(url: url)
        self.onDone = onDone
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the SafariViewController as a child
        addChild(safariViewController)
        view.addSubview(safariViewController.view)
        safariViewController.view.frame = view.bounds
        safariViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        safariViewController.didMove(toParent: self)
        
        // Add a navigation bar with a Done button
        let navigationBar = UINavigationBar(frame: .zero)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        
        // Adjust SafariViewController's frame to account for the navigation bar
        safariViewController.view.frame = CGRect(
            x: 0,
            y: 44,
            width: view.bounds.width,
            height: view.bounds.height - 44
        )
    }
}

// UIViewControllerRepresentable for the custom Safari view
struct SafariView: UIViewControllerRepresentable {
    let urlString: String
    let onDone: () -> Void
    
    func makeUIViewController(context: Context) -> SafariWrapperViewController {
        SafariWrapperViewController(urlString: urlString, onDone: onDone)
    }
    
    func updateUIViewController(_ uiViewController: SafariWrapperViewController, context: Context) {
        // No dynamic updates needed
    }
}

// SwiftUI View that uses the SafariView
public struct NewsWebView: View {
    let urlString: String
    @EnvironmentObject var router: Router

    public var body: some View {
        ZStack {
            SafariView(urlString: urlString) {
                // Dismiss the view when Done is tapped
                router.navigateBackInAuth()
            }
            .edgesIgnoringSafeArea(.all)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.midnightblue)
    }
}

#Preview {
    NewsWebView(urlString: "https://www.apple.com")
}
