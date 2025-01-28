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
    @State private var isLoading: Bool = false
    @State private var isContinue: Bool = false
    @State private var isRestore: Bool = false
    @State private var emptyProductAlert: Bool = false
    @State private var isShowAlert = false
    @State private var alertMessage = ""
    //    private let features: [String] = ["Remove all ads", "Daily new content", "Other cool features", "Follow for more tutorials"]
    // MARK: - Layout
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    router.navigateBackInAuth()
                }, label: {
                    Image(.back)
                        .foregroundColor(.black)
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
                        await subscriptionsManager.loadProducts()
                        print(subscriptionsManager.purchasedProductIDs)
                        subscriptionsManager.returnPurchaseTitle()
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
        .alert("Please select a product before purchasing.", isPresented: $emptyProductAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    // MARK: - Views
    private var hasSubscriptionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "crown.fill")
                .foregroundStyle(.yellow)
                .font(Font.system(size: 100))
            
            Text("You've Unlocked Pro Access")
                .font(.system(size: 30.0, weight: .bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .ignoresSafeArea(.all)
    }
    
    private var subscriptionOptionsView: some View {
        VStack(alignment: .center, spacing: 12.5) {
            proAccessView
            if !subscriptionsManager.products.isEmpty {
                ScrollView {
                    VStack(spacing: 2.5) {
                        VStack(spacing:20) {
                            VStack {
                                HStack {
                                    Text("Status")
                                    Spacer()
                                    if isLoading {
                                        ProgressView()
                                    } else {
                                        if let subscriptionPayload = subscriptionsManager.latestPayload , let _ = subscriptionPayload.productId , let dateStr = subscriptionPayload.subscriptionEndDate , let date = convertToDate(from: dateStr) ,date >= Date(){
                                            Text("Active")
                                                .foregroundStyle(.blue)
                                                .onAppear {
                                                    print(date)
                                                    print(Date())
                                                }
                                        } else {
                                            Text("Inactive")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                }
                                Divider()
                            }
                            VStack {
                                HStack {
                                    Text("Plan")
                                    Spacer()
                                    if isLoading {
                                        ProgressView()
                                    } else {
                                        if let subscriptionPayload = subscriptionsManager.latestPayload, let plane = subscriptionPayload.productId {
                                            if plane == IAPConstants.Products.monthlySubscription {
                                                Text("Monthly")
                                                    .foregroundStyle(.blue)
                                            } else {
                                                Text("Yearly")
                                                    .foregroundStyle(.blue)
                                            }
                                        } else {
                                            Text("Free")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                    
                                }
                                Divider()
                            }
                            VStack {
                                HStack {
                                    Text("Renew Date")
                                    Spacer()
                                    if isLoading {
                                        ProgressView()
                                    } else {
                                        if let subscriptionPayload  = subscriptionsManager.latestPayload, let date = subscriptionPayload.subscriptionEndDate {
                                            Text(formatDate(from: date) ?? "None")
                                                .foregroundStyle(.blue)
                                        } else {
                                            Text("None")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                }
                                Divider()
                            }
                        }
                        .padding(.horizontal,20)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        productsListView
                        
                        VStack {
                            purchaseButtonView
                                .padding(.top,20)
                                .alert(isPresented: $isShowAlert) {
                                    Alert(title: Text("Purchase Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                                }
                            
                            Button("Restore Purchases") {
                                Task {
                                    isRestore = true
                                    await subscriptionsManager.restorePurchases()
                                }
                            }
                            .font(.system(size: 16.0, weight: .semibold, design: .rounded))
                            .frame(height: 16, alignment: .center)
                            .foregroundColor(.midnightBlue)
                            .padding(.top,10)
                            .disabled(subscriptionsManager.isLoading)
                        }
                        
                        
                    }
                    Spacer()
                }
                
            } else {
                Spacer()
                ProgressView()
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
            Text("Subscription")
                .font(.system(size: 33.0, weight: .bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal,20)
    }
    
    //    private var featuresView: some View {
    //        List(features, id: \.self) { feature in
    //            HStack(alignment: .center) {
    //                Image(systemName: "checkmark.circle")
    //                    .font(.system(size: 22.5, weight: .medium))
    //                    .foregroundStyle(.midnightBlue)
    //
    //                Text(feature)
    //                    .font(.system(size: 17.0, weight: .semibold, design: .rounded))
    //                    .multilineTextAlignment(.leading)
    //            }
    //            .listRowSeparator(.hidden)
    //            .frame(height: 35)
    //        }
    //        .scrollDisabled(true)
    //        .listStyle(.plain)
    //        .padding(.vertical, 20)
    //    }
    
    private var productsListView: some View {
        List(subscriptionsManager.products, id: \.self) { product in
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
        .frame(height: CGFloat(subscriptionsManager.products.count) * 90, alignment: .bottom)
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
                    if let url = URL(string: "https://loremipsum.io/privacy-policy") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Terms & Conditions")
                        .font(.system(size: 14.0, weight: .regular, design: .rounded))
                        .frame(height: 15, alignment: .center)
                        .foregroundColor(.midnightBlue)
                }
                
                Spacer()
                
                Button {
                    if let url = URL(string: "https://loremipsum.io/privacy-policy") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Privacy Policy")
                        .font(.system(size: 14.0, weight: .regular, design: .rounded))
                        .frame(height: 15, alignment: .center)
                        .foregroundColor(.midnightBlue)
                }
            }
            
        }.padding(.horizontal, 15)
    }
    
    private var purchaseButtonView: some View {
        
        Button(action: {
            if let selectedProduct = subscriptionsManager.selectedProduct {
                if let  _ = subscriptionsManager.latestTransactionId ,subscriptionsManager.latestPayload == nil  {
                    isShowAlert = true
                    alertMessage = "This item has already been purchased by another user from this Apple ID"
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
            RoundedRectangle(cornerRadius: 12.5)
                .foregroundColor( subscriptionsManager.selectedProduct == nil ? .midnightBlue.opacity(0.4) : .midnightBlue)
                .overlay {
                    VStack {
                        if subscriptionsManager.isLoading && isContinue {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(subscriptionsManager.title)
                                .foregroundStyle(.white)
                                .font(.system(size: 16.5, weight: .semibold, design: .rounded))
                        }
                    }
                }
                .padding(.horizontal, 20)
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
    
    
    // MARK: Subscription Item
    struct SubscriptionItemView: View {
        @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
        
        var product: Product
        @Binding var selectedProduct: Product?
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 12.5)
                    .stroke(selectedProduct == product ? .midnightBlue : .gray, lineWidth: 2.0)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.5)))
                
                HStack {
                    VStack(alignment: .leading, spacing: 8.5) {
                        Text(product.displayName)
                            .font(.system(size: 16.0, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.leading)
                        
                        Text("Get full access for just \(product.displayPrice)")
                            .font(.system(size: 14.0, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: selectedProduct == product ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedProduct == product ? .midnightBlue : .gray)
                }
                .padding(.horizontal, 20)
                .frame(height: 65, alignment: .center)
            }
            .onTapGesture {
                selectedProduct = product
            }
            .disabled(subscriptionsManager.isViewDisabled(title: subscriptionsManager.title, product: product.id))
            .listRowSeparator(.hidden)
        }
    }
}
//#Preview {
//    SubscriptionsView()
//}
