//
//  AsyncPublisherBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: AsyncPublisher เป็นคลาสที่เกี่ยวข้องกับการสร้างและจัดการกับ Publisher ใน Combine framework โดยมีความสามารถในการส่งข้อมูลแบบ asynchronous ผ่านช่องทางของ async และ await
// ในรูปแบบที่สามารถใช้งานร่วมกับ concurrency model ของ Swift ได้ เช่นในการใช้งานร่วมกับ async/await และ concurrency model ใหม่อื่นๆ เช่น Task และ Actor

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    
    // ใช้เพื่อเก็บข้อมูลที่จะถูกส่งไปยัง AsyncPublisherBootcampViewModel ผ่านทาง Combine publisher.
    @Published var myData: [String] = []
    
    // MARK: ฟังก์ชันที่ใช้ async/await สำหรับการเพิ่มข้อมูลลงใน myData โดยมีการรอให้แต่ละการเพิ่มข้อมูลเสร็จสิ้นด้วย Task.sleep เพื่อจำลองการทำงานที่อยู่ใน background.
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
    }
    
}

class AsyncPublisherBootcampViewModel: ObservableObject {
    
    // ใช้เพื่อเก็บข้อมูลที่ได้รับจาก Combine publisher โดยมีการใช้ @MainActor เพื่อระบุว่าเซ็ตค่าตัวแปรที่เป็นส่วนหลักของ UI เมื่อมีการอัปเดต.
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    // เรียกใช้ addSubscribers() เพื่อเริ่มต้นการติดตาม Combine publisher.
    init() {
        addSubscribers()
    }
    
    // MARK: ฟังก์ชันนี้มีการใช้ for await value in manager.$myData.values เพื่อติดตามการเปลี่ยนแปลงของ publisher และทำการอัปเดต dataArray โดยใช้ await MainActor.run
    private func addSubscribers() {
        Task {
            for await value in manager.$myData.values {
                await MainActor.run(body: {
                    self.dataArray = value
                })
            }
        }
        
//        Task {
//            for await value in manager.$myData.values {
//                await MainActor.run(body: {
//                    self.dataArray = value
//                })
//            }
//        }
        
//        manager.$myData
//            .receive(on: DispatchQueue.main, options: nil)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
    }
    
    // MARK:  ฟังก์ชันที่ใช้เริ่มต้นการเพิ่มข้อมูลโดยเรียกใช้ manager.addData() โดยใช้ async/await.
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherBootcamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherBootcamp()
}
