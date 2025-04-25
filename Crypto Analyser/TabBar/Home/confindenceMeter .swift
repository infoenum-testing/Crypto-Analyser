//
//  confindenceMeter .swift
//  Crypto Analyser
//
//  Created by IE15 on 25/04/25.
//

import SwiftUI

struct ConfidenceMeter: View {
    let value: Double
    var body: some View {
            VStack {
                ChartWebView(htmlContent: """
            <!DOCTYPE html>
            <html lang="en">
            <head>
               <style>
                .gauge {
              width: 100%;
              max-width: 800px;
              font-family: "Roboto", sans-serif;
              font-size: 32px;
              color: #004033;
            }
            .gauge__body {
              width: 100%;
              height: 0;
              padding-bottom: 50%;
              background: #b4c0be;
              position: relative;
              border-top-left-radius: 100% 200%;
              border-top-right-radius: 100% 200%;
              overflow: hidden;
            }
            .gauge__fill {
              position: absolute;
              top: 100%;
              left: 0;
              width: inherit;
              height: 100%;
              background: #009578;
              transform-origin: center top;
              transform: rotate(0.25turn);
              transition: transform 0.2s ease-out;
            }
            .gauge__cover {
              width: 75%;
              height: 150%;
              background: #ffffff;
              border-radius: 50%;
              position: absolute;
              top: 25%;
              left: 50%;
              transform: translateX(-50%);
              /* Text */
              display: flex;
              align-items: center;
              justify-content: center;
              padding-bottom: 15%;
              box-sizing: border-box;
              font-size: 90px; 
              font-weight: bold; 
              color: #004033;
            }
               </style>
            </head>
            <body>
                <div class="gauge">
                    <div class="gauge__body">
                      <div class="gauge__fill"></div>
                      <div class="gauge__cover"></div>
                    </div>
                  </div>
            <script>
                const gaugeElement = document.querySelector(".gauge");
            function setGaugeValue(gauge, value) {
              if (value < 0 || value > 1) {
                return;
              }
              gauge.querySelector(".gauge__fill").style.transform = `rotate(${
                value / 2
              }turn)`;
              gauge.querySelector(".gauge__cover").textContent = `${Math.round(
                value * 100
              )}%`;
            }
            setGaugeValue(gaugeElement,\(value / 100));
            </script>
            </body>
            </html>
            """)
            }
            .frame(width: 250,height: 200)
    }
}

#Preview {
    ConfidenceMeter(value: 80)
}
