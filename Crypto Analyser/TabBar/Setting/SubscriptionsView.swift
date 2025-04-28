//
//  SubscriptionsView.swift
//  Crypto Analyser
//
//  Created by IE MacBook Pro 2014 on 02/01/25.
//

import SwiftUI
import StoreKit

struct SubscriptionsView: View {
    // MARK: - Properties
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
    @EnvironmentObject var router: Router
    //  @State private var selectedProduct: Product? = nil
    @State private var subscriptionPayload: SubscriptionPayload?
    @State private var isOnAppear: Bool = false
    @State private var isLoading: Bool = false
    @State private var isContinue: Bool = false
    @State private var isRestore: Bool = false
    @State private var emptyProductAlert: Bool = false
    @State private var isShowAlert = false
    @State private var alertMessage = ""
    @StateObject private var borderAnimationViewModel = BorderAnimationViewModel()
    
    // MARK: - Layout
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    router.navigateBackInAuth()
                }, label: {
                    Image(.back)
                        .foregroundColor(.white)
                })
                .disabled(subscriptionsManager.isLoading)
                Spacer()
                if subscriptionsManager.isLoading && isRestore {
                    ProgressView()
                }
            }
            .padding(.horizontal,20)
            subscriptionOptionsView
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
                .onAppear {
                    Task {
                        subscriptionsManager.returnPurchaseTitle()
                        await subscriptionsManager.loadProducts()
                        await subscriptionsManager.updatePurchasedProducts()
                        subscriptionsManager.fetchActiveProducts(originalTransactionId: "2000000821674742", isSandbox: true) { result in
                            switch result {
                            case .success(let activeProducts):
                                print("Active products: \(activeProducts)")
                            case .failure(let error):
                                print("Error fetching active products: \(error)")
                            }
                        }
                        
                    }
                }
        }
        .alert(StringConstants.pleaseSelectProduct, isPresented: $emptyProductAlert) {
            Button(StringConstants.ok, role: .cancel) { }
        }
        .background(Color.themecolorprimary)
    }
    
    // MARK: - Views
    
    //        private var hasSubscriptionView: some View {
    //            VStack(spacing: 20) {
    //                Image(systemName: "crown.fill")
    //                    .foregroundStyle(.yellow)
    //                    .font(Font.system(size: 100))
    //
    //                Text("You've Unlocked Pro Access")
    //                    .font(.system(size: 30.0, weight: .bold))
    //                    .multilineTextAlignment(.center)
    //                    .padding(.horizontal, 30)
    //            }
    //            .ignoresSafeArea(.all)
    //        }
    
    private var subscriptionOptionsView: some View {
        VStack(alignment: .center, spacing: 12.5) {
            proAccessView
            if !subscriptionsManager.products.isEmpty {
                ScrollView {
                    VStack(spacing: 2.5) {
                        VStack(spacing:20) {
                            VStack {
                                HStack {
                                    Text(StringConstants.status)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    if isLoading {
                                        ProgressView()
                                    } else {
                                        if let subscriptionPayload = subscriptionsManager.latestPayload , let _ = subscriptionPayload.productId , let dateStr = subscriptionPayload.subscriptionEndDate , let date = convertToDate(from: dateStr) ,date >= Date(){
                                            Text(StringConstants.active)
                                                .foregroundStyle(.pink)
                                                .onAppear {
                                                    print(date)
                                                    print(Date())
                                                }
                                        } else {
                                            Text(StringConstants.inActive)
                                                .foregroundStyle(.pink)
                                                .task {
                                                    await subscriptionsManager.updatePurchasedProducts()
                                                }
                                        }
                                    }
                                }
                                Divider()
                                    .background(.white)
                            }
                            VStack {
                                HStack {
                                    Text(StringConstants.plan)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    if isLoading {
                                        ProgressView()
                                    } else {
                                        if let subscriptionPayload = subscriptionsManager.latestPayload, let plane = subscriptionPayload.productId {
                                            if plane == IAPConstants.Products.monthlySubscription {
                                                Text(StringConstants.monthly)
                                                    .foregroundStyle(.pink)
                                            } else {
                                                Text(StringConstants.yearly)
                                                    .foregroundStyle(.pink)
                                            }
                                        } else {
                                            Text(StringConstants.free)
                                                .foregroundStyle(.pink)
                                        }
                                    }
                                    
                                }
                                Divider()
                                    .background(.white)
                            }
                            VStack {
                                HStack {
                                    Text(StringConstants.renewDate)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    if isLoading {
                                        ProgressView()
                                    } else {
                                        if let subscriptionPayload  = subscriptionsManager.latestPayload, let date = subscriptionPayload.subscriptionEndDate {
                                            Text(formatDate(from: date) ?? StringConstants.none)
                                                .foregroundStyle(.pink)
                                        } else {
                                            Text(StringConstants.none)
                                                .foregroundStyle(.pink)
                                        }
                                    }
                                }
                                Divider()
                                    .background(.white)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        productsListView
                        
                        VStack {
                            purchaseButtonView
                                .padding(.top,20)
                                .alert(isPresented: $isShowAlert) {
                                    Alert(title: Text(StringConstants.purchaseAlert), message: Text(alertMessage), dismissButton: .default(Text(StringConstants.ok)))
                                }
                            
                            Button(StringConstants.restorePurchases) {
                                Task {
                                    isRestore = true
                                    await subscriptionsManager.restorePurchases()
                                }
                            }
                            .font(.system(size: 16.0, weight: .semibold, design: .rounded))
                            .frame(height: 16, alignment: .center)
                            .foregroundColor(.white)
                            .padding(.top,10)
                            .disabled(subscriptionsManager.isLoading)
                        }
                    }
                    Spacer()
                }
                
            } else {
                Spacer()
                ProgressView()
                    .tint(Color.pink)
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .ignoresSafeArea(.all)
                Spacer()
            }
            purchaseSection
        }
        .onAppear{payLoadData()}
    }
    
    private func payLoadData() {
        let email = UserSessionManager.getUserEmail()
        Task {
            isLoading = true
            await subscriptionsManager.getSubscriptionDetails(for: email) { result in
                isLoading = false
                switch result {
                case .success(let subscriptionPayload):
                    self.subscriptionPayload = subscriptionPayload
                    // Save to UserDefaults or handle the payload as needed
                case .failure(let error):
                    print("Failed to fetch subscription details: \(error.localizedDescription)")
                }
            }
        }
        
    }
    
    private func formatDate(from inputDateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d, yyyy"
        
        if let date = inputFormatter.date(from: inputDateString) {
            return outputFormatter.string(from: date)
        } else {
            return nil // Return nil if the input date string is invalid
        }
    }
    
    private var proAccessView: some View {
        HStack() {
            Text(StringConstants.subscription)
                .foregroundStyle(.white)
                .font(.system(size: 33.0, weight: .bold))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    private var productsListView: some View {
        ForEach(subscriptionsManager.products, id: \.self) { product in
            if let subscriptionPayload = subscriptionsManager.latestPayload , let plan = subscriptionPayload.productId {
                if product.id != plan {
                    SubscriptionItemView(product: product, selectedProduct: $subscriptionsManager.selectedProduct)
                } else if let date = subscriptionPayload.subscriptionEndDate, convertToDate(from: date) ?? Date() < Date() {
                    SubscriptionItemView(product: product, selectedProduct: $subscriptionsManager.selectedProduct)
                }
            } else {
                SubscriptionItemView(product: product, selectedProduct: $subscriptionsManager.selectedProduct)
            }
        }
        .scrollDisabled(true)
        .listStyle(.plain)
        .listRowSpacing(2.5)
    }
    
    private func convertToDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // Format matches the input string
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Match the +0000 timezone
        
        return dateFormatter.date(from: dateString)
    }
    
    private var purchaseSection: some View {
        VStack(alignment: .center, spacing: 15) {
            
            HStack {
                Button {
                    if let url = URL(string: StringConstants.privacyPolicyURL) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text(StringConstants.termsAndConditions)
                        .font(.system(size: 14.0, weight: .regular, design: .rounded))
                        .frame(height: 15, alignment: .center)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button {
                    if let url = URL(string: StringConstants.privacyPolicyURL) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text(StringConstants.privacyPolicy)
                        .font(.system(size: 14.0, weight: .regular, design: .rounded))
                        .frame(height: 15, alignment: .center)
                        .foregroundColor(.white)
                }
            }
            
        }.padding(.horizontal, 15)
    }
    
    private var purchaseButtonView: some View {
        
        Button(action: {
            if let selectedProduct = subscriptionsManager.selectedProduct {
                if let  _ = subscriptionsManager.latestTransactionId ,subscriptionsManager.latestPayload == nil  {
                    isShowAlert = true
                    alertMessage = StringConstants.alreadyPurchasedDes
                } else {
                    Task {
                        isContinue = true
                        await subscriptionsManager.buyProduct(selectedProduct)
                    }
                }
            } else {
                emptyProductAlert = true
                print("Please select a product before purchasing.")
            }
        }) {
            HStack {
                RoundedRectangle(cornerRadius: 12.5)
                    .foregroundColor( subscriptionsManager.selectedProduct == nil ? .buttonbackgroundtheme.opacity(0.4) : .buttonbackgroundtheme)
                    .overlay {
                        ZStack {
                            if subscriptionsManager.isLoading && isContinue {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(subscriptionsManager.title)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16.5, weight: .semibold, design: .rounded))
                            }
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: borderAnimationViewModel.gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 4)
                                .blur(radius: 2)
                                .frame(height: 46)
                        }
                    }
                    .padding(.horizontal,2.5)
                    .frame(height: 46)
                    .disabled(subscriptionsManager.selectedProduct == nil)
                    .onChange(of: subscriptionsManager.isLoading, perform: { value in
                        if value == false {
                            isRestore = false
                            isContinue = false
                        }
                    })
            }
        }
        .onAppear {borderAnimationViewModel.startColorAnimation()}
        .onDisappear {borderAnimationViewModel.stopColorAnimation()}
    }
    
    
    // MARK: Subscription Item
    struct SubscriptionItemView: View {
        @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
        
        var product: Product
        @Binding var selectedProduct: Product?
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 12.5)
                    .stroke(selectedProduct == product ? .white : .clear, lineWidth: 2.0)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.5)))
                
                HStack {
                    VStack(alignment: .leading, spacing: 8.5) {
                        Text(product.displayName == "AutoRenewableOneYear" ? StringConstants.yearly : StringConstants.monthly)
                            .foregroundStyle(.white)
                            .font(.system(size: 18.0, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.leading)
                        
                        Text("Get full access for just \(product.displayPrice)")
                            .foregroundStyle(.white)
                            .font(.system(size: 14.0, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: selectedProduct == product ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedProduct == product ? .white : .gray)
                }
                .padding(.horizontal, 20)
                .frame(height: 65, alignment: .center)
            }
            .onTapGesture {
                selectedProduct = product
            }
            .disabled(subscriptionsManager.isViewDisabled(title: subscriptionsManager.title, product: product.id))
            .listRowSeparator(.hidden)
            .frame(height: 65, alignment: .center)
            .padding(.vertical,5)
            .padding(.horizontal,1)
        }
    }
}

//#Preview {
//    SubscriptionsView()
//}
