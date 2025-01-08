//
//  AnalyseView.swift
//  Crypto Analyser
//
//  Created by IE15 on 26/12/24.
//

import SwiftUI

struct ImageAnalyserView: View {
    @EnvironmentObject var router: Router
    let image: UIImage
    @StateObject var viewModel = ChatGPTData()
    @State private var isItFirst = true
    @State private var isLoading: Bool = true
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    router.navigateBackInAuth()
                }, label: {
                    Image(.back)
                        .foregroundColor(.black)
                })
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 50)
            .clipped()
            
            VStack {
                Spacer()
                
                ZStack {
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: 300)
                            .clipped()
                            .contentShape(Rectangle())  // Make sure the image is tappable if needed
                    }
                    .frame(height: 300)
                    
                    if isLoading {
                        LeafLoadingView()
                    }
                }
                Spacer()
            }
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
            switch result {
            case .success(let success):
                isLoading = false
                if let content = success.choices?.first?.message?.content {
                    if content.replacingOccurrences(of: " ", with: "")
                        .lowercased() == "false" {
                        alertTitle = "Invalid"
                        alertMessage = "The provided image is not a crypto chart. Please upload a valid crypto chart for analysis."
                        showAlert = true
                    } else {
                        let email = UserSessionManager.getUserData().email
                        FireBaseResentSearches.shared.addRecentSearch(email: email, image: image, title: "", message: content, completion: { result in
                            removeLastRecentSearch()
                            print("Save in recent Search",result)
                        })
                        isItFirst = false
                        router.navigateToAuth(.dataDescription(afterAnalyse: true,title: nil, message: content))
                    }
                }
            case .failure(let error):
                isLoading = false
                alertTitle = "Error"
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
                if recentSearches.count >= 10,let earliestObject = recentSearches.min(by: { $0.date < $1.date }) {
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

#Preview {
    ImageAnalyserView(image: UIImage())
}
