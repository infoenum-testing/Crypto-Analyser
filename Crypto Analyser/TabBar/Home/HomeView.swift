//
//  HomeView.swift
//  Crypto Analyser
//
//  Created by IE15 on 21/12/24.
//

import SwiftUI

struct HomeView: View {
    enum AlertType {
        case delete
        case purchase
    }
    @EnvironmentObject var subscriptionsManager: SubscriptionsManager
    @EnvironmentObject var router: Router
    
    @State public var image: UIImage? = nil
    @State private var isGallery: Bool = false
    @State private var isLoading: Bool = false
    @State private var recentSearchIsLoading: Bool = false
    @State private var isPlanActive: Bool = true
    @State private var isCamera: Bool = false
    @State private var coins:[Coin]?
    @State private var resentSearches:[SearchDetails] = []
    @State private var showAlert = false
    @State private var itemToDelete: SearchDetails?
    @State private var trail:Int?
    
    @StateObject var viewModel = ChatGPTData()
    @StateObject var searchViewModel = SearchViewModel()
    @StateObject private var borderAnimationViewModel = BorderAnimationViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(StringConstants.analyseCrypto)
                            .foregroundStyle(.white)
                            .font(.system(size: 25, weight: .semibold))
                        Spacer()
                    }
                    HStack {
                        //                        Spacer()
                        customButton(imageName: "camera", title: StringConstants.takeAPic, action: {
                            if let trail = trail, let isActive =  subscriptionsManager.isPlanActive, trail <= 3 || isActive {
                                isCamera = true
                            } else {
                                showAlert = true
                            }
                        })
                        .frame(maxWidth: .infinity)
                        
                        Text(StringConstants.or)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                        customButton(imageName: "photo.on.rectangle", title: StringConstants.uploadFromGallery, action: {
                            if let trail = trail, let isActive =  subscriptionsManager.isPlanActive, trail < 3 || isActive {
                                isGallery = true
                            } else {
                                showAlert = true
                            }
                        })
                        .frame(maxWidth: .infinity)
                        
                        Text(StringConstants.or)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                        customButton(imageName: "magnifyingglass", title: StringConstants.searchForCoin, action: {
                            if let trail = trail, let isActive =  subscriptionsManager.isPlanActive, trail <= 3 || isActive {
                                router.navigateToAuth(.searchCoin)
                            } else {
                                showAlert = true
                            }
                        })
                        .frame(maxWidth: .infinity)
                        //  Spacer()
                    }
                }
                .padding(.horizontal,20)
                
                Text(StringConstants.qualityCoins)
                    .font(.system(size: 20, weight: .regular))
                    .padding(.bottom,5)
                    .padding(.horizontal,20)
                    .foregroundStyle(.white)
                VStack {
                    if let coins , !coins.isEmpty{
                        ScrollView(showsIndicators: false) {
                            ForEach(coins, id: \.symbol) { coin in
                                CoinRowView(coin: coin)
                                    .onTapGesture {
                                        if let trail = trail, let isActive =  subscriptionsManager.isPlanActive, trail <= 3 || isActive {
                                            router.navigateToAuth(.searchView(symbol: coin.symbol))
                                        } else {
                                            showAlert = true
                                        }
                                    }
                            }
                            .padding(.top,2)
                            .padding(.horizontal,20)
                        }
                    } else if let coins ,coins.isEmpty{
                        VStack {
                            Spacer()
                            Text("No Data Availble")
                            Spacer()
                        }
                    } else {
                        VStack {
                            Spacer()
                            ProgressView()
                                .controlSize(.large)
                                .foregroundColor(.white)
                                .tint(Color.pink)
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top,10)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: borderAnimationViewModel.gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 4) // Gradient border
                        .blur(radius: 5) // Glow effect
                        .mask(
                            VStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 40)
                                Rectangle()
                                    .frame(height: 18)
                                    .opacity(0)
                            }
                        )
                )
                .padding(.horizontal,14)
            }
            .fullScreenCover(isPresented: $isGallery) {
                GalleryView(isGallery: $isGallery, capturedImage: $image)
            }
            .fullScreenCover(isPresented: $isCamera) {
#if targetEnvironment(simulator)
                VStack {
                    Text("simulator")
                }
                .onAppear {
                    isCamera = false
                }
#else
                CameraPicker(image: $image)
                    .ignoresSafeArea(.all)
#endif
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Free Trial Ended"),
                    message: Text("You've used all 3 free trials. Unlock full access by purchasing the feature."),
                    primaryButton: .default(Text("Buy Now")) {
                        router.navigateToAuth(.subscription)
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
            
        }
        .background(Color.themecolor)
        .onAppear {
            fetchCoins()
            getUserTrails()
        }
        .onChange(of: image) { value in
            if let value {
                router.navigateToAuth(.imageAnalyser(image: value, fromSearch: false))
            }
        }
    }
    
    private func fetchCoins() {
        searchViewModel.fetchCryptoData { result in
            switch result {
            case .success(let cryptoData):
                coins = cryptoData.data.coins
            case .failure(let error):
//                showAlert = true
//                alertMessage = "\(error.localizedDescription)"
                print("Error fetching data: \(error.localizedDescription)")
            }
        }
    }
    
    private func customButton(imageName: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 25, height: 25, alignment: .center)
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white)
            }
        })
        .frame(width: 90, height: 90)
        .background(Color.buttonbackground)
        .cornerRadius(45)
        .overlay(
            RoundedRectangle(cornerRadius: 45)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: borderAnimationViewModel.gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 4)
                .blur(radius: 2)
        )
        .accentColor(.black)
        .foregroundColor(.black)
        .font(.system(size: 20))
        .padding(.bottom)
        .onAppear {borderAnimationViewModel.startColorAnimation()}
        .onDisappear {borderAnimationViewModel.stopColorAnimation()}
        
    }
    
    private func getUserTrails() {
        let email = UserSessionManager.getUserData().email
        FirebaseAuthentication.shared.getTrial(email: email) { result in
            switch result {
            case .success(let trialCount):
                self.trail = trialCount
                UserSessionManager.saveUserTrail(count: trialCount)
            case .failure(let error):
                self.trail = 0
                print("Error fetching trial: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    HomeView()
}
