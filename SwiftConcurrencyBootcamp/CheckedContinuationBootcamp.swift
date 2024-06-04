//
//  CheckedContinuationBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: CheckedContinuation ใช้เพื่อทำงานกับ asynchronous และ completion handlers
// โดยใช้ async/await เพื่อปรับโค้ดที่ทำงานกับ completion handlers ให้สามารถใช้งานได้ในลักษณะ asynchronous ซึ่งทำให้โค้ดอ่านง่ายขึ้นและจัดการกับการทำงานแบบ asynchronous ได้สะดวกขึ้น

import SwiftUI

class CheckedContinuationBootcampNetworkManager {
    
    // ฟังก์ชันดาวน์โหลดข้อมูลจาก URL โดยใช้ async/await.
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            return data
        } catch {
            throw error
        }
    }
    
    // ฟังก์ชันดาวน์โหลดข้อมูลจาก URL
    func getData2(url: URL) async throws -> Data {
        
        // ใช้ withCheckedThrowingContinuation เพื่อแปลง completion handler เป็น asynchronous function.
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    // ฟังก์ชันจำลองการดึงภาพจากฐานข้อมูลโดยใช้ completion handler.
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    // ฟังก์ชันดึงภาพจากฐานข้อมูล
    func getHeartImageFromDatabase() async -> UIImage {
        
        // ใช้ withCheckedContinuation เพื่อแปลง completion handler เป็น asynchronous function.
        await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
    
}

class CheckedContinuationBootcampViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationBootcampNetworkManager()
    
    // ฟังก์ชันสำหรับดาวน์โหลดภาพจาก URL และแปลงเป็น UIImage.
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
            let data = try await networkManager.getData2(url: url)
            
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            print(error)
        }
    }
    
    // ฟังก์ชันสำหรับดึงภาพหัวใจจากฐานข้อมูล.
    func getHeartImage() async {
        self.image = await networkManager.getHeartImageFromDatabase()
    }
    
}

struct CheckedContinuationBootcamp: View {
    
    // ใช้ @StateObject เพื่อเก็บ ViewModel.
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        
        // ใช้ viewModel.getHeartImage() ผ่าน task.
        .task {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

#Preview {
    CheckedContinuationBootcamp()
}
