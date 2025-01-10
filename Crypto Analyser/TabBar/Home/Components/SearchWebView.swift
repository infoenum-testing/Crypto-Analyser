//
//  SearchWebView.swift
//  Crypto Analyser
//
//  Created by IE15 on 09/01/25.
//

import SwiftUI
import WebKit

struct SearchWebView: View {
    @Binding var screenshot: UIImage?
    @Binding var capture: Bool

    var body: some View {
        VStack {
            ChartWebView(htmlContent: """
            <!-- TradingView Widget BEGIN -->
            <div class="tradingview-widget-container" style="height:100%;width:100%">
              <div class="tradingview-widget-container__widget" style="height:calc(100% - 32px);width:100%"></div>
              <div class="tradingview-widget-copyright"><a href="https://www.tradingview.com/" rel="noopener nofollow" target="_blank"><span class="blue-text">Track all markets on TradingView</span></a></div>
              <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js" async>
              {
              "autosize": true,
              "symbol": "CME:BTC1!",
              "interval": "D",
              "timezone": "Etc/UTC",
              "theme": "light",
              "style": "1",
              "locale": "en",
              "allow_symbol_change": true,
              "save_image": false,
              "calendar": false,
              "support_host": "https://www.tradingview.com"
            }
              </script>
            </div>
            <!-- TradingView Widget END -->
            """)
            .edgesIgnoringSafeArea(.all)
            .onChange(of: capture, perform: { _ in
                captureScreenshot()
            })
        }
    }
    
    private func captureScreenshot() {
      if let webView = findWebView(in: UIApplication.shared.windows.first?.rootViewController?.view) {
                let renderer = UIGraphicsImageRenderer(size: webView.frame.size)
                let image = renderer.image { context in
                    webView.layer.render(in: context.cgContext)
                }
                screenshot = image
            }
    }
    
    // Helper function to find the WKWebView instance in the view hierarchy
    private func findWebView(in view: UIView?) -> WKWebView? {
        if let webView = view as? WKWebView {
            return webView
        }
        
        for subview in view?.subviews ?? [] {
            if let webView = findWebView(in: subview) {
                return webView
            }
        }
        return nil
    }
}

struct ChartWebView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
