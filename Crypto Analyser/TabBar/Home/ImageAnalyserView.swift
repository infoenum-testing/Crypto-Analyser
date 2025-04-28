//
//  AnalyseView.swift
//  Crypto Analyser
//
//  Created by IE15 on 26/12/24.
//
import SwiftUI

struct ImageAnalyserView: View {
    @StateObject private var borderAnimationViewModel = BorderAnimationViewModel()
    @EnvironmentObject var router: Router
    let backTo:Int
    let image: UIImage
    @StateObject var viewModel = ChatGPTData()
    @State private var isItFirst = true
    @State private var isLoading: Bool = true
    @State private var isDataFound: Bool = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var message = ""
    @State private var confidenceLevel = "0"
    
    @Namespace private var animationNamespace
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                        router.navigateBackInAuth(count: backTo)
                }, label: {
                    Image(.back)
                        .foregroundColor(.white)
                })
                Spacer()
                Text(StringConstants.analysedResult)
                    .foregroundStyle(.white)
                    .font(.system(size: 25, weight: .semibold))
                Spacer()
                Text(" ")
            }
            .padding(.horizontal, 0)
            .frame(height: 30)
            
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center) {
                        VStack {
                            if !isDataFound {
                                Spacer()
                            }
                            VStack {
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width - 40)
                                        .frame(maxHeight: UIScreen.main.bounds.height/2.3)
                                        .clipped()
                                    if isLoading {
                                        LeafLoadingView()
                                    }
                                }
                                .cornerRadius(8)
                                    .clipped() 
                            }
                            .frame(maxHeight: UIScreen.main.bounds.height/2.5)
                            .cornerRadius(8)
                            .shadow(color: Color.black, radius: 3, x: 0, y: 0)
                            .padding(.top, !isDataFound ? 0 : 10)
                            
                            if !isDataFound {
                                Spacer()
                                Spacer()
                            }
                        }
                        .frame(height: !isDataFound ? UIScreen.main.bounds.height: UIScreen.main.bounds.height/2.5)
                        if isDataFound {
                            Text(message)
                                .foregroundStyle(.white)
                                .font(.system(size: 20, weight: .regular))
                                .multilineTextAlignment(.leading)
                                .padding(.top, 20)
                                .transition(.opacity)
                            ConfidenceMeter(value: Double(confidenceLevel) ?? 50)
                                   .padding(.leading,UIScreen.main.bounds.width * 0.1)
                        }
                    }
                }
            }
            .animation(.easeIn, value: isLoading)
        }
        .padding(.top, 5)
        .onAppear {
            if isItFirst {
                refreshUI()
            }
        }
        .padding(.horizontal, 20)
        .background(Color.themecolorprimary)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(StringConstants.message),
                message: Text(alertMessage),
                dismissButton: .default(Text(StringConstants.ok), action: {
                    router.navigateBackInAuth()
                })
            )
        }
    }
    
    private func refreshUI() {
        let imageStr = image.resized(to: 800).toBase64String()
        viewModel.analyseImageData(imageBase64: imageStr ?? "", completion: { result in
            isLoading = false
            switch result {
            case .success(let success):
                if let signal = success.signal, signal.replacingOccurrences(of: " ", with: "").lowercased() == "false" {
                    alertTitle = StringConstants.invalid
                    alertMessage = StringConstants.invalidImageAlertMessage
                    showAlert = true
                } else if let content =  success.techAnalysis ,let level =  success.confidenceLevel,let signal = success.signal{
                    let email = UserSessionManager.getUserData().email
                    let confLevel = level.replacingOccurrences(of: "%", with: "")
                    FireBaseResentSearches.shared.addRecentSearch(email: email, image: image,signal: signal, confidenceLevel: confLevel, message: content, completion: { result in
                        removeLastRecentSearch()
                        print("Saved in recent Search", result)
                    })
                    isItFirst = false
                    message = content
                    confidenceLevel = confLevel
                    withAnimation {
                        isDataFound = true
                    }
                    let trail = FirebaseAuthentication.shared.trail ?? 0
                    FirebaseAuthentication.shared.updateTrial(email: email, trail:  trail + 1) { result in
                        print(result)
                    }
                }
                
            case .failure(let error):
                alertTitle = StringConstants.error
                alertMessage = "An error occurred: \(error.localizedDescription)"
                showAlert = true
            }
        })
    }
    
    func removeLastRecentSearch() {
        let email = UserSessionManager.getUserData().email
        FireBaseResentSearches.shared.fetchRecentSearches(for: email) { result in
            switch result {
            case .success(let recentSearches):
                if recentSearches.count >= 10, let earliestObject = recentSearches.min(by: { $0.date < $1.date }) {
                    print(earliestObject.message)
                    FireBaseResentSearches.shared.removeRecentSearch(for: email, documentID: earliestObject.id) { result in
                        switch result {
                        case .success:
                            print("Deleted last search")
                        case .failure(let error):
                            print("Failed to remove recent search: \(error.localizedDescription)")
                        }
                    }
                }
            case .failure(let error):
                print("Failed to fetch recent searches: \(error.localizedDescription)")
            }
        }
    }
}
