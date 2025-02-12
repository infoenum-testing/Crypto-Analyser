//
//  DataDescriptionView.swift
//  Crypto Analyser
//
//  Created by IE15 on 02/01/25.
//

import SwiftUI

struct DataDescriptionView: View {
    @EnvironmentObject var router: Router
    let image: UIImage
    let afterAnalyse:Bool
    let confidenceLevel: String
    let message: String
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    router.navigateBackInAuth()
                }, label: {
                    Image(.back)
                        .foregroundColor(.white)
                })
                Spacer()
                Text(StringConstants.analysedResult)
                    .foregroundColor(.white)
                    .font(.system(size: 25, weight: .semibold))
                Spacer()
                Text(" ")
            }
            .padding(.horizontal, 20)
            .frame(height: 30)
            .clipped()
            
            ZStack {
                ScrollView(showsIndicators: false)  {
                    VStack {
                        VStack {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width - 40)
                                    .frame(maxHeight: UIScreen.main.bounds.height/2.3)
                                    .clipped()
                            }
                            .frame(maxHeight: UIScreen.main.bounds.height/2.5)
                            .cornerRadius(8)
                            .shadow(color: Color.black, radius: 3, x: 0, y: 0)
                            .padding(.top, 20)
                        }
                        Text(message)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .transition(.opacity)
                        //                        ChartWebView(htmlContent: """
                        //<html><head><style>
                        //  body {
                        //      background-color: #0E0C32;
                        //      display: flex;
                        //      justify-content: center;
                        //      align-items: center;
                        //      height: 100vh;
                        //      margin: 0;
                        //  }
                        //.ring {
                        //  position: relative;
                        //  --pointerleft: 11%;
                        //  --pointertop: 11%;
                        //  --pointerdeg: -45deg;
                        //  width: 50vmin;
                        //  height: 50vmin;
                        // background-color: #0E0C32;
                        //            background-image:
                        //                radial-gradient(red 0, red 50%, transparent 50%, transparent 100%),
                        //                radial-gradient(green 0, green 50%, transparent 50%, transparent 100%),
                        //                radial-gradient(#0E0C32 0, #0E0C32 60%, transparent 60%), /* Inner ring color changed */
                        //                conic-gradient(orange 0, green 130deg, #0E0C32 130deg, #0E0C32 230deg, red 230deg, orange 360deg);
                        //  background-size: 11% 11%, 11% 11%, 100% 100%, 100% 100%;
                        //  background-repeat: no-repeat;
                        //  background-position: 9.2% 82.3%, 90.8% 82.3%, center center, center center;
                        //  border-radius: 50%;
                        //  border-style: none;
                        //}
                        //
                        //.ring::after {
                        //  position: absolute;
                        //  content: '';
                        //  width: 5%;
                        //  height: 15%;
                        //  left: var(--pointerleft);
                        //  top: var(--pointertop);
                        //  transform: rotate(var(--pointerdeg));
                        //  border-style: solid;
                        //  border-width: 0.5vmin;
                        //  border-radius: 2vmin;
                        //  background-color: White;
                        //}
                        //
                        //.speed {
                        //  display: inline-block;
                        //  position: absolute;
                        //  top: 50%;
                        //  left: 50%;
                        //  transform: translateX(-50%) translateY(-50%);
                        //  text-align: center;
                        //  color: white;
                        //}
                        //
                        //.speed .number {
                        //  font-size: 6vw;
                        //}
                        //
                        //.speed .units {
                        //  font-size: 3vw;
                        //}
                        //</style>
                        //<!-- Just semi circle -->
                        //</head><body style="
                        //    display: flex;
                        //    justify-content: center;
                        //    align-items: center;
                        //    height: 50vh;
                        //"><div class="ring">
                        //  <div class="speed">
                        //    <div class="number">\(confidenceLevel)</div>
                        //    <div class="units" style=";">conf%</div>
                        //  </div>
                        //</div>
                        //
                        //</body></html>
                        //""")
                        
                    }
                }
            }
        }
        .background(Color.themecolor)
    }
}

#Preview {
    DataDescriptionView(image: UIImage(), afterAnalyse: false, confidenceLevel: "50", message: "")
}
