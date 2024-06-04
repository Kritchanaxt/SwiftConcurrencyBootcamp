//
//  TaskGroupBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//


// MARK: Task Group ใช้เพื่อจัดการการดึงภาพจาก URL หลาย ๆ URL พร้อมกันอย่างมีประสิทธิภาพ
// การใช้ async/await, async let, และ withThrowingTaskGroup เพื่อแสดงการทำงานแบบขนาน (concurrent) ใน Swift

import SwiftUI

// ตัวจัดการข้อมูลสำหรับการใช้งาน Task Group
class TaskGroupBootcampDataManager {
    
    // ฟังก์ชันที่ใช้ async let เพื่อดึงภาพพร้อมกัน
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        // ดึงภาพจาก URL หลาย ๆ URL พร้อมกัน
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/300")
        
        // รอผลลัพธ์ของทุก async let แล้วนำมารวมกันเป็น array
        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        return [image1, image2, image3, image4]
    }
    
    // ฟังก์ชันที่ใช้ Task Group เพื่อดึงภาพพร้อมกัน
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        // URL ของภาพ
        let urlStrings = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
        ]
        // ใช้ withThrowingTaskGroup เพื่อจัดการ Task Group
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count)
            
            // เพิ่ม Task ในกลุ่มงาน
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            // รอผลลัพธ์จากกลุ่มงานแล้วรวมเป็น array
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    // ฟังก์ชันที่ดึงภาพจาก URL
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

// ViewModel สำหรับการใช้งานใน SwiftUI
class TaskGroupBootcampViewModel: ObservableObject {
    
    @Published var images: [UIImage] = []
    let manager = TaskGroupBootcampDataManager()

    // ฟังก์ชันที่ดึงภาพและอัปเดต View
    func getImages() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}


struct TaskGroupBootcamp: View {
    
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group 🥳")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

#Preview {
    TaskGroupBootcamp()
}
