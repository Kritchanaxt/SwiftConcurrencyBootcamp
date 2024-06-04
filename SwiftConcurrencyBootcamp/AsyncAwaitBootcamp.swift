//
//  AsyncAwaitBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: ใช้สำหรับการจัดการงานแบบ asynchronous (แบบไม่ประสาน)
// โดยใช้ GCD (Grand Central Dispatch) และ async/await เพื่อเพิ่มข้อมูลลงใน dataArray หลังจากเวลาที่กำหนดไว้

import SwiftUI

// ประกาศคลาสที่ conform กับ ObservableObject เพื่อให้ SwiftUI สามารถสังเกตการเปลี่ยนแปลงของข้อมูลภายในคลาสนี้ได้.
class AsyncAwaitBootcampViewModel: ObservableObject {
    
    // ประกาศตัวแปร dataArray ซึ่งจะถือข้อมูลประเภทสตริง และจะมีการเผยแพร่เมื่อมีการเปลี่ยนแปลง.
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        
        //ใช้เพื่อรันโค้ดบล็อกบน main thread หลังจากเวลา 2 วินาที โดยเพิ่มสตริงลงใน dataArray.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title1 : \(Thread.current)")
        }
    }
    
    func addTitle2() {
        
        // ใช้ DispatchQueue.global().asyncAfter(deadline:) เพื่อรันโค้ดบล็อกบน global background thread หลังจากเวลา 2 วินาที
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "Title2 : \(Thread.current)"
            
            // เพิ่มสตริงลงใน dataArray และต่อมาสลับกลับไป main thread เพื่อเพิ่มสตริงอีกครั้ง.
            DispatchQueue.main.async {
                self.dataArray.append(title)
                
                let title3 = "Title3 : \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    
    
    // MARK:  ฟังก์ชันแบบ asynchronous ที่รันบน main thread
    func addAuthor1() async {
        
        // เพิ่มสตริงแรกลงใน dataArray แล้ว
        let author1 = "Author1 : \(Thread.current)"
        self.dataArray.append(author1)
        
        // หยุด 2 วินาทีด้วย Task.sleep
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let author2 = "Author2 : \(Thread.current)"
        
        // หลังจากนั้นเพิ่มสตริงสองและสามลงใน dataArray โดยใช้ MainActor.run.
        await MainActor.run(body: {
            self.dataArray.append(author2)
            
            let author3 = "Author3 : \(Thread.current)"
            self.dataArray.append(author3)
        })
    }
    
    // MARK: ฟังก์ชันแบบ asynchronous
    func addSomething() async {
        
        // หยุด 2 วินาทีด้วย Task.sleep
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something1 = "Something1 : \(Thread.current)"
        
        // เพิ่มสตริงหนึ่งและสองลงใน dataArray โดยใช้ MainActor.run.
        await MainActor.run(body: {
            self.dataArray.append(something1)
            
            let something2 = "Something2 : \(Thread.current)"
            self.dataArray.append(something2)
        })
        
    }
    
    
}

struct AsyncAwaitBootcamp: View {
    
    @StateObject private var viewModel = AsyncAwaitBootcampViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor1()
                await viewModel.addSomething()
                
                let finalText = "FINAL TEXT : \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        }
    }
}

#Preview {
    AsyncAwaitBootcamp()
}
