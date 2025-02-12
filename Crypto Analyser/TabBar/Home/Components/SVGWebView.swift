//
//  SVGWebView.swift
//  Crypto Analyser
//
//  Created by IE15 on 12/02/25.
//

import SwiftUI
import WebKit

struct SVGWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Load SVG content directly
        fetchSVGContent(from: url) { svgContent in
            DispatchQueue.main.async {
                let svgHTML = """
                <html>
                <head>
                    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0"/>
                    <style>
                        body { margin: 0; padding: 0; display: flex; align-items: center; justify-content: center; background-color: transparent; }
                        svg { width: 100%; height: 100%; }
                    </style>
                </head>
                <body>
                    \(svgContent) <!-- Directly insert SVG data -->
                </body>
                </html>
                """
                uiView.loadHTMLString(svgHTML, baseURL: nil)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SVGWebView

        init(_ parent: SVGWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
    }

    /// Fetch SVG raw content as a string
    func fetchSVGContent(from url: URL, completion: @escaping (String) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let svgString = String(data: data, encoding: .utf8) {
                completion(svgString)
            } else {
                completion("") // Fallback if fetch fails
            }
        }.resume()
    }
}
