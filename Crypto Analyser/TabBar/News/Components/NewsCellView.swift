//
//  NewsCellView.swift
//  Crypto Analyser
//
//  Created by IE15 on 10/02/25.
//

import SwiftUI

struct NewsCellView: View {
    let imageUrl: String
    let title: String
    let newsUrl: String
    let des: String
    var newsUrlAction:() -> Void
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 150, height: 100)
                .clipShape(.rect(cornerRadius: 0))
                Text(title)
                    .foregroundStyle(.orange)
                    .onTapGesture {
                        newsUrlAction()
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
            }
            Text(des)
                .foregroundStyle(.white)
        }
        .padding(8)
        .background(Color.cellcolortheme)
        .cornerRadius(8)
    }
}


