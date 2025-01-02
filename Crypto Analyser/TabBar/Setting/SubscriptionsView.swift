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
    @State private var selectedProduct: Product? = nil
    @State private var emptyProductAlert: Bool = false
    private let features: [String] = ["Remove all ads", "Daily new content", "Other cool features", "Follow for more tutorials"]
    
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
                Spacer()
                Text("Subscriptions")
                    .font(.system(size: 30, weight: .semibold))
                
                Spacer()
                Text("")
            }
            .padding(.horizontal,20)
            subscriptionOptionsView
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
                .onAppear {
                    Task {
                        await subscriptionsManager.loadProducts()
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
            if !subscriptionsManager.products.isEmpty {
                proAccessView
                VStack(spacing: 2.5) {
                    productsListView
                    VStack {
                        purchaseButtonView
                            .padding(.top,20)
                        
                        Button("Restore Purchases") {
                            Task {
                                await subscriptionsManager.restorePurchases()
                            }
                        }
                        .font(.system(size: 16.0, weight: .semibold, design: .rounded))
                        .frame(height: 16, alignment: .center)
                        .foregroundColor(.midnightBlue)
                        .padding(.top,10)
                    }
                   

                }
                Spacer()
                purchaseSection
            } else {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .ignoresSafeArea(.all)
                Spacer()
            }
        }
    }
    
    private var proAccessView: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "dollarsign.circle.fill")
                .foregroundColor(.midnightBlue)
                .font(Font.system(size: 80))
            
            Text("Unlock Pro Access")
                .font(.system(size: 33.0, weight: .bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
            
        }
    }
    
    private var featuresView: some View {
        List(features, id: \.self) { feature in
            HStack(alignment: .center) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 22.5, weight: .medium))
                    .foregroundStyle(.midnightBlue)
                
                Text(feature)
                    .font(.system(size: 17.0, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.leading)
            }
            .listRowSeparator(.hidden)
            .frame(height: 35)
        }
        .scrollDisabled(true)
        .listStyle(.plain)
        .padding(.vertical, 20)
    }
    
    private var productsListView: some View {
        List(subscriptionsManager.products, id: \.self) { product in
            SubscriptionItemView(product: product, selectedProduct: $selectedProduct)
        }
        .scrollDisabled(true)
        .listStyle(.plain)
        .listRowSpacing(2.5)
        .frame(height: CGFloat(subscriptionsManager.products.count) * 90, alignment: .bottom)
    }
    
    private var purchaseSection: some View {
        VStack(alignment: .center, spacing: 15) {
            
           
            
            HStack {
                Button {
                    //
                } label: {
                    Text("Terms & Conditions")
                        .font(.system(size: 14.0, weight: .regular, design: .rounded))
                        .frame(height: 15, alignment: .center)
                        .foregroundColor(.midnightBlue)
                }
                
                Spacer()
                
                Button {
                    //
                } label: {
                    Text("Privacy Policy")
                        .font(.system(size: 14.0, weight: .regular, design: .rounded))
                        .frame(height: 15, alignment: .center)
                        .foregroundColor(.midnightBlue)
                }
            }
            
           
        }
    }
    
    private var purchaseButtonView: some View {
        Button(action: {
            if let selectedProduct = selectedProduct {
                Task {
                    await subscriptionsManager.buyProduct(selectedProduct)
                }
            } else {
                emptyProductAlert = true
                print("Please select a product before purchasing.")
            }
        }) {
            RoundedRectangle(cornerRadius: 12.5)
                .foregroundColor( selectedProduct == nil ? .midnightBlue.opacity(0.4) : .midnightBlue)
                .overlay {
                    Text("Purchase")
                        .foregroundStyle(.white)
                        .font(.system(size: 16.5, weight: .semibold, design: .rounded))
                }
        }
        .padding(.horizontal, 20)
        .frame(height: 46)
        .disabled(selectedProduct == nil)
    }
}


// MARK: Subscription Item
struct SubscriptionItemView: View {
    var product: Product
    @Binding var selectedProduct: Product?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .stroke(selectedProduct == product ? .midnightBlue : .gray, lineWidth: 2.0)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            
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
        .listRowSeparator(.hidden)
    }
}



#Preview {
    SubscriptionsView()
}
