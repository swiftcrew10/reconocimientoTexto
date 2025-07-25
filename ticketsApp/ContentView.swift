//
//  ContentView.swift
//  ticketsApp
//
//  Created by UwU on 29/06/25.
//

import SwiftUI
import PhotosUI

@available(iOS 26.0, *)
struct ContentView: View {
    
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingCamera: Bool = false
    @State private var recognizedText: String = ""
    
    private let recognizer = TextRecognizer()
    
    var body: some View {
        VStack {
            //Display the selected image
            
            if let img = selectedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    
                
                
                ScrollView {
                    Text(recognizedText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            } else {
                Text("No image selected")
                    .foregroundStyle(.secondary)
            }
            
            //photo picker button
            
            
            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ){
                Text("Select photo")
                    .foregroundStyle(.blue)
                    .frame(width: 200, height: 50)
                    
                    
                
            }
            .glassEffect(.regular)
            .onChange(of: selectedItem) { item in
                guard let item = item else { return }
                Task {
                    // 1) load the image data
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img  = UIImage(data: data),
                       let cg   = img.cgImage
                    {
                        // 2) assign to @State so your UI can react
                        selectedImage = img
                        
                        // 3) run Vision on it
                        recognizer.recognize(cg,keywords: ["total", "Fecha:", "precio"]) { text in
                            DispatchQueue.main.async {
                                recognizedText = text.map { "\($0.key): \($0.value)" }.joined(separator: "\n")


                            }
                        }
                    }
                }
            }
            
            
        }
            
            .padding()
            
            
        }
    }


#Preview {
    if #available(iOS 26.0,*){
        ContentView()
    } else{
        
    }
    
}
