//
//  DownloadImageAsync.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// วิธีการดาวน์โหลดรูปภาพจาก URL โดยใช้เทคนิคต่าง ๆ ใน Swift:
// escaping closures, Combine framework, และ async/await pattern ใน SwiftUI

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        
        // ตรวจสอบว่ามีข้อมูล (data) และการตอบกลับ (response) ถูกต้องหรือไม่
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            
            // ตรวจสอบสถานะการตอบกลับ HTTP ว่าอยู่ในช่วง 200-299 (ประสบความสำเร็จ)
            response.statusCode >= 200 && response.statusCode < 300 else {
            
                // ถ้าไม่คืนค่า nil
                return nil
            }
        
        // ถ้าทุกอย่างถูกต้อง จะคืนค่าภาพ (UIImage)
        return image
    }
    
    // ใช้ escaping closure เพื่อส่งคืนภาพที่ดาวน์โหลดมา หรือข้อผิดพลาด
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        
        // ใช้ URLSession เพื่อสร้าง data task, และใช้ handleResponse ในการตรวจสอบข้อมูลที่ดาวน์โหลดมา
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume()
    }
    
    // ใช้ Combine framework ในการสร้าง publisher ที่จะส่งคืนภาพที่ดาวน์โหลดมา
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        
        // ใช้ dataTaskPublisher ของ URLSession เพื่อสร้าง publisher
        URLSession.shared.dataTaskPublisher(for: url)
            
            // ใช้ map เพื่อแปลงข้อมูลดิบเป็นภาพ
            .map(handleResponse)
        
            // ใช้ mapError เพื่อจัดการข้อผิดพลาด
            .mapError({ $0 })
            
            // ใช้ eraseToAnyPublisher เพื่อซ่อนชนิดของ publisher
            .eraseToAnyPublisher()
    }
    
    // ใช้ async/await pattern เพื่อดาวน์โหลดข้อมูลแบบ asynchronous
    func downloadWithAsync() async throws -> UIImage? {
        do {
            
            // ใช้ URLSession.shared.data(from:) เพื่อดาวน์โหลดข้อมูล
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            
            // ใช้ handleResponse เพื่อตรวจสอบและแปลงข้อมูล
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
    
}

class DownloadImageAsyncViewModel: ObservableObject {
    
    // ตัวแปร @Published สำหรับเก็บภาพที่ดาวน์โหลดมา
    @Published var image: UIImage? = nil
    
    // อินสแตนซ์ของ DownloadImageAsyncImageLoader สำหรับเรียกฟังก์ชันดาวน์โหลดภาพ
    let loader = DownloadImageAsyncImageLoader()
    
    // เก็บข้อมูลเกี่ยวกับการสมัครรับข้อมูล (subscriptions) ที่จะถูกยกเลิกเมื่อไม่จำเป็น
    var cancellables = Set<AnyCancellable>()
    
    // MARK: ฟังก์ชัน asynchronous สำหรับเรียกใช้งานฟังก์ชันดาวน์โหลดภาพแบบต่างๆ
    func fetchImage() async {
        /*
         
         // MARK: สามารถเลือกใช้สามวิธีนี้ ในการดาวน์โหลดภาพ

         // MARK: Escaping closure
//        loader.downloadWithEscaping { [weak self] image, error in
//            DispatchQueue.main.async {
//                self?.image = image
//            }
//        }
         
         // MARK: Combine
//        loader.downloadWithCombine()
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//
//            } receiveValue: { [weak self] image in
//                self?.image = image
//            }
//            .store(in: &cancellables)
        */
        
        // MARK: async/await
        // ใช้ async/await โดยเรียก downloadWithAsync
        let image = try? await loader.downloadWithAsync()
        
        // ใช้ MainActor.run เพื่อให้แน่ใจว่าการปรับปรุง UI เกิดขึ้นใน main thread
        await MainActor.run {
            self.image = image
        }
    }
    
}

struct DownloadImageAsync: View {
    
    // ใช้งาน @StateObject เพื่อสร้างอินสแตนซ์ของ DownloadImageAsyncViewModel
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}

