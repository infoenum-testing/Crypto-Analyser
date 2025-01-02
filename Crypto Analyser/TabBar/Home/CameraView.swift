//
//  CameraView.swift
//  Crypto Analyser
//
//  Created by IE15 on 24/12/24.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @Binding public var isCamera: Bool
    @State private var showCameraView: Bool = true
    @State private var isCapturing: Bool = true
    @State private var previewImage: UIImage?
    @State private var closure: (() -> Void)?
    let session = AVCaptureSession()
    let output = AVCapturePhotoOutput()

    var captureImage: (UIImage?) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                if let capturedImage = previewImage {
                    // Show captured image
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: UIScreen.main.bounds.height + 15)
                    
                } else if showCameraView {
                    // Show Camera View
                    ZStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .foregroundColor(.orange)
                            .scaleEffect(1.5)
                            .padding()
                            .cornerRadius(10)
                        
                        CameraPreview(capturedImage: $previewImage, closure: $closure,session: session,output: output)
                            .ignoresSafeArea()
                    }
                    
                }
            }
            . frame(height: UIScreen.main.bounds.height)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isCamera = false
                    }, label: {
                        Image(systemName: "xmark.square.fill")
                            .resizable()
                            .foregroundColor(Color.midnightBlue)
                            .frame(width: 50,height: 50)
                    })
                }
                Spacer()
            }
            .padding(.top,50)
            .padding(.trailing,24)
            .frame(maxWidth: UIScreen.main.bounds.width, alignment: .center)
            
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Button(action: {
                        // Retake action
                        previewImage = nil
                        showCameraView = true
                        isCapturing = true
                    }) {
                        Text("Retake")
                            .foregroundColor(.white)
                            .opacity(previewImage == nil ? 0.5 :1.0)
                            .font(.custom("Gilroy", size: 20).weight(.bold))
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Button(action: capturePhoto) {
                        ZStack {
                            Circle()
                                .fill(Color.midnightBlue)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(color: Color.orange.opacity(0.3), radius: 7.5, x: 5, y: 5)
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "camera")
                                .foregroundColor(.white)
                        }
                        
                    }
                    .disabled(!isCapturing) // Disable button while capturing
                    .opacity(!isCapturing ? 0.5 : 1.0)
                    
                    Spacer()
                    
                    Button(action: {
                        isCamera = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            captureImage(previewImage)
                        }
                    }) {
                        Text("Done")
                            .foregroundColor(.white)
                            .opacity(previewImage == nil ? 0.5 :1.0)
                            .font(.custom("Gilroy", size: 20).weight(.bold))
                    }
                    .padding(.trailing)
                    .disabled(previewImage == nil)
                }
            }
            .padding([.horizontal, .top], 20)
            .padding(.bottom,50)
            .frame(maxWidth: UIScreen.main.bounds.width, alignment: .center)
            .background(Color.black.opacity(0.2))
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onAppear {
            

#if targetEnvironment(simulator)
            previewImage = UIImage(named: "defaultFood") // Set the default image on simulator
#else
//            capturedImage = nil // Set to nil on a real device
#endif
        }
    }

    private func capturePhoto() {
        if isCapturing {
            isCapturing = false
            closure?()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var closure: (() -> Void)?
     let session: AVCaptureSession
     let output: AVCapturePhotoOutput

    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraPreview
        init(parent: CameraPreview) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.parent.capturedImage = image
                self.parent.session.stopRunning() // Stop session when photo is captured
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        configureSession(in: view, context: context)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if capturedImage == nil && !session.isRunning {
            startSession()
        }
    }
    
    private func configureSession(in view: UIView, context: Context) {
        session.sessionPreset = .photo
        view.backgroundColor = .black

        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return // Handle no camera available case
        }
        
        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()
        startSession()

        DispatchQueue.main.async {
            closure = {
                let settings = AVCapturePhotoSettings()
                output.capturePhoto(with: settings, delegate: context.coordinator)
            }
        }
    }

    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.session.isRunning {
                self.session.startRunning() // Start the session on a background thread
            }
        }
    }
    
    private func dismantleUIView(_ uiView: UIView, context: Context) {
        stopSession()
    }
    
    private func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning {
                self.session.stopRunning() // Stop the session on a background thread
            }
        }
    }
}



#Preview {
    CameraView(isCamera: .constant(true), captureImage: {
        _ in
        //
    })
}
