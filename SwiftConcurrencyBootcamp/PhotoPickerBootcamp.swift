//
//  PhotoPickerBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: PhotosPicker ใช้งานเพื่อเลือกและแสดงรูปภาพจาก Photo Library บนอุปกรณ์ iOS โดยแบ่งออกเป็นสองส่วนหลัก: ViewModel และ View

import SwiftUI
import PhotosUI

// ใช้ @MainActor เพื่อให้แน่ใจว่าทุกฟังก์ชันในคลาสนี้จะทำงานบน main thread
@MainActor

// สร้างคลาส PhotoPickerViewModel ที่ conform กับ ObservableObject เพื่อใช้ในการจัดการข้อมูลและสถานะของการเลือกภาพ
final class PhotoPickerViewModel: ObservableObject {
    
    // ประกาศ properties ต่างๆ ที่เกี่ยวข้องกับการเลือกภาพ
    // @Published จะทำให้ SwiftUI สามารถติดตามและอัปเดต view เมื่อค่าเปลี่ยนแปลง
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        
        // ใช้ didSet เพื่อตั้งค่าเรียกฟังก์ชัน setImage(from:) และ setImages(from:) เมื่อมีการเปลี่ยนแปลง
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published private(set) var selectedImages: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        
        // ใช้ didSet เพื่อตั้งค่าเรียกฟังก์ชัน setImage(from:) และ setImages(from:) เมื่อมีการเปลี่ยนแปลง
        didSet {
            setImages(from: imageSelections)
        }
    }

    // ฟังก์ชัน setImage(from:) ใช้ในการโหลดภาพจาก PhotosPickerItem ที่เลือก และตั้งค่าให้กับ selectedImage
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        // ใช้ Task เพื่อรันโค้ดแบบ asynchronous บน main thread
        Task {
//            if let data = try? await selection.loadTransferable(type: Data.self) {
//                if let uiImage = UIImage(data: data) {
//                    selectedImage = uiImage
//                    return
//                }
//            }
            
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                
                selectedImage = uiImage
            } catch {
                print(error)
            }
        }
    }
    
    // ฟังก์ชัน setImages(from:) ใช้ในการโหลดภาพจากหลาย PhotosPickerItem ที่เลือก และตั้งค่าให้กับ selectedImages
    private func setImages(from selections: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            for selection in selections {
                if let data = try? await selection.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }
            
            selectedImages = images
        }
    }
}

struct PhotoPickerBootcamp: View {
    
    @StateObject private var viewModel = PhotoPickerViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Hello, World!")
            
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            }
            
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Text("Open the photo picker!")
                    .foregroundColor(.red)
            }
            
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            
            PhotosPicker(selection: $viewModel.imageSelections, matching: .images) {
                Text("Open the photos picker!")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    PhotoPickerBootcamp()
}
