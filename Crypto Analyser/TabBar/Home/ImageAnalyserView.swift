//
//  AnalyseView.swift
//  Crypto Analyser
//
//  Created by IE15 on 26/12/24.
//
import SwiftUI

struct ImageAnalyserView: View {
    @EnvironmentObject var router: Router
    let fromSearch:Bool
    let image: UIImage
    @StateObject var viewModel = ChatGPTData()
    @State private var isItFirst = true
    @State private var isLoading: Bool = true
    @State private var isDataFound: Bool = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var message = ""
    
    @Namespace private var animationNamespace
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if fromSearch {
                        router.navigateBackInAuth(count: 2)
                    } else {
                        router.navigateBackInAuth()
                    }
                }, label: {
                    Image(.back)
                        .foregroundColor(.black)
                })
                Spacer()
                Text("Analysed Result")
                    .font(.system(size: 25, weight: .semibold))
                Spacer()
                Text(" ")
            }
            .padding(.horizontal, 20)
            .frame(height: 30)
            .clipped()
            
            ZStack {
                ScrollView {
                    VStack {
                        VStack {
                            if !isDataFound {
                                Spacer()
                            }
                            VStack {
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: UIScreen.main.bounds.width - 16)
                                        .frame(maxHeight: UIScreen.main.bounds.height/2.3)
                                        .clipped()
                                    if isLoading {
                                        LeafLoadingView()
                                    }
                                }
                            }
                            .frame(maxHeight: UIScreen.main.bounds.height/2.5)
                            .cornerRadius(8)
                            .shadow(color: Color.black, radius: 3, x: 0, y: 0)
                            .padding(.horizontal, 20)
                            .padding(.top, !isDataFound ? 0 : 10)
                          
                            if !isDataFound {
                                Spacer()
                                Spacer()
                            }
                        }
                        .frame(height: !isDataFound ? UIScreen.main.bounds.height: UIScreen.main.bounds.height/2.5)
                        if isDataFound {
                            Text(message)
                                .font(.system(size: 20, weight: .regular))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .transition(.opacity)
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"), action: {
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
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { 
                    if let content = success.choices?.first?.message?.content {
                        if content.replacingOccurrences(of: " ", with: "").lowercased() == "false" {
                            alertTitle = StringConstants.invalid
                            alertMessage = StringConstants.invalidImageAlertMessage
                            showAlert = true
                        } else {
                            let email = UserSessionManager.getUserData().email
                            FireBaseResentSearches.shared.addRecentSearch(email: email, image: image, title: "", message: content, completion: { result in
                                removeLastRecentSearch()
                                print("Saved in recent Search", result)
                            })
                            isItFirst = false
                            message = content
                            withAnimation {
                                isDataFound = true
                            }
                            
                            FirebaseAuthentication.shared.updateTrial(email: email, trail: UserSessionManager.getUserTrail() + 1) { result in
                                print(result)
                            }
                            UserSessionManager.saveUserTrail(count: UserSessionManager.getUserTrail() + 1)
                        }
                    }
//                }
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
