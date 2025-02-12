//
//  GalleryView.swift
//  Crypto Analyser
//
//  Created by IE15 on 24/12/24.
//

import SwiftUI
import UIKit
import Foundation

struct GalleryView: View {
    @Binding var isGallery: Bool
    @Binding var capturedImage: UIImage?
    var body: some View {
        ImagePickerView(selectedImage: $capturedImage, isPresented: $isGallery, sourceType: .photoLibrary)
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType
    
    // Coordinator to handle UIImagePickerControllerDelegate events
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var selectedImage: UIImage?
        @Binding var isPresented: Bool
        
        init(selectedImage: Binding<UIImage?>, isPresented: Binding<Bool>) {
            _selectedImage = selectedImage
            _isPresented = isPresented
        }
        
        // Handle image selection
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                selectedImage = image
            }
            isPresented = false // Dismiss the gallery view
        }
        
        // Handle cancellation
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isPresented = false // Dismiss the gallery view
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedImage: $selectedImage, isPresented: $isPresented)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType // Use the specified source type
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

