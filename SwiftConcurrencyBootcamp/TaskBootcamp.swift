//
//  TaskBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: ใช้ Task และ async/await สำหรับการดาวน์โหลดภาพจากอินเทอร์เน็ตและการแสดงผลในแอปพลิเคชัน  โดยมีการจัดการการประมวลผลแบบ asynchronous ภายใน ViewModel และ View ต่าง ๆ 
// เพื่อให้การจัดการงานใน background และการอัพเดท UI บน main thread ทำได้อย่างมีประสิทธิภาพและมีความง่ายในการอ่านมากขึ้น.

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    
    // ตัวแปรเหล่านี้จะถูกใช้งานเพื่อเก็บภาพที่ถูกดาวน์โหลดและแสดงใน View.
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil

    func fetchImage() async {
        
        // รอเป็นเวลา 5 วินาที
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        
//        for x in array {
//            // work
//            try Task.checkCancellation()
//        }
        
        do {
            // ทำการดาวน์โหลดภาพจาก URL ที่กำหนด.
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            // หากดาวน์โหลดสำเร็จ ภาพจะถูกตั้งค่าให้กับตัวแปร image บน main thread.
            await MainActor.run(body: {
                self.image = UIImage(data: data)
                print("IMAGE RETURNED SUCCESSFULLY!")
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // ฟังก์ชันนี้คล้ายกับ fetchImage แต่ไม่มีการหยุดรอก่อนการดาวน์โหลดภาพ.
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskBootcampHomeView: View {
    
    var body: some View {
        
        // ใช้สำหรับแสดง navigation stack ที่จะช่วยในการนำทางระหว่าง views ต่าง ๆ ในแอปพลิเคชัน.
        NavigationView {
            ZStack {
                NavigationLink("CLICK ME! 🤓") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    
    // สร้าง instance ของ TaskBootcampViewModel ที่จะถูกใช้งานใน view นี้.
    @StateObject private var viewModel = TaskBootcampViewModel()
//    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        
        // ใช้สำหรับการจัดเรียง view ภายในในแนวตั้ง โดยมีระยะห่างระหว่างแต่ละองค์ประกอบเป็น 40.
        VStack(spacing: 40) {
            
            // แสดงภาพถ้ามีข้อมูลภาพในตัวแปร image และ image2 จาก ViewModel.
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        
        // เรียกใช้งานฟังก์ชัน fetchImage เมื่อ view ปรากฏขึ้น.
        .task {
            await viewModel.fetchImage()
        }
        
        // MARK: การแสดงผล (onDisappear).
//        .onDisappear {
//            fetchImageTask?.cancel()
//        }
//        .onAppear {
//            fetchImageTask = Task {
//                await viewModel.fetchImage()
//            }
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
            
        // MARK: การใช้งาน Task กับลำดับความสำคัญต่าง ๆ เพื่อแสดงลำดับความสำคัญของงาน.
//            Task(priority: .high) {
////                try? await Task.sleep(nanoseconds: 2_000_000_000)
//                await Task.yield()
//                print("high : \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .userInitiated) {
//                print("userInitiated : \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .medium) {
//                print("medium : \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .low) {
//                print("low : \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .utility) {
//                print("utility : \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .background) {
//                print("background : \(Thread.current) : \(Task.currentPriority)")
//            }
            
            
//            Task(priority: .low) {
//                print("low : \(Thread.current) : \(Task.currentPriority)")
                
            // MARK: ใช้งาน Task.detached เพื่อสร้างงานที่ไม่ขึ้นกับลำดับความสำคัญของงานหลัก.
        
//                Task.detached {
//                    print("detached : \(Thread.current) : \(Task.currentPriority)")
//                }
//            }
            
            
            
            
            
//        }
    }
}

#Preview {
    TaskBootcamp()
}
