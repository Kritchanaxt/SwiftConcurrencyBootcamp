//
//  StrongSelfBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: การใช้ strong reference และ weak reference ใน closure โดยโฟกัสที่การอ้างอิง self ใน Task เพื่อป้องกันหรือสร้าง strong reference cycles ตามความจำเป็น

import SwiftUI

// // คลาสที่ให้บริการข้อมูล ใช้ async/await เพื่อคืนค่าข้อมูลจากการเรียกใช้งานภายใน data service.
final class StrongSelfDataService {
    
    func getData() async -> String {
        "Updated data!"
    }
    
}

// ViewModel นี้เป็นตัวจัดการข้อมูลและการอัปเดต UI
final class StrongSelfBootcampViewModel: ObservableObject {
    
    // ใช้เพื่อเก็บข้อมูลและอัปเดต UI ทันที.
    @Published var data: String = "Some title!"
    let dataService = StrongSelfDataService()
    
    private var someTask: Task<Void, Never>? = nil
    private var myTasks: [Task<Void, Never>] = []

    func cancelTasks() {
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach({ $0.cancel() })
        myTasks = []
    }
    
    // This implies a strong reference...
    // MARK: ฟังก์ชันนี้ใช้ Task เพื่ออัปเดตข้อมูล UI โดยการเรียกใช้งาน dataService.getData() โดยตรง.
    func updateData() {
        Task {
            data = await dataService.getData()
        }
    }
    
    // This is a strong reference...
    // MARK: ฟังก์ชันนี้เหมือนกับ updateData() แต่ใช้ self ในการอ้างถึงตัวเองอย่างชัดเจน.
    func updateData2() {
        Task {
            self.data = await self.dataService.getData()
        }
    }
    
    // This is a strong reference...
    // MARK: ฟังก์ชันนี้ใช้คำสั่ง [self] เพื่อแนบตัวเองเข้าไปใน closure เพื่อให้เข้าถึงตัวแปร data ได้อย่างชัดเจน.
    func updateData3() {
        Task { [self] in
            self.data = await self.dataService.getData()
        }
    }
    
    // This is a weak reference
    // MARK: ฟังก์ชันนี้ใช้ [weak self] เพื่อป้องกัน strong reference cycle และเลือกที่จะอัปเดตข้อมูลเมื่อ self ยังคงอยู่.
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }
    
    // We don't need to manage weak/strong
    // We can manage the Task!
    // MARK: ฟังก์ชันนี้จัดการ Task โดยตรงโดยการเก็บ Task เอาไว้ในตัวแปร someTask เพื่อให้สามารถยกเลิกได้.
    func updateData5() {
        someTask = Task {
            self.data = await self.dataService.getData()
        }
    }
    
    // We can manage the Task!
    // MARK: ฟังก์ชันนี้สร้าง Task และเก็บในตัวแปร myTasks เพื่อจัดการหลาย Task พร้อมกัน.
    func updateData6() {
        let task1 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task1)
        
        let task2 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task2)
    }
    
    // We purposely do not cancel tasks to keep strong references
    // MARK: ฟังก์ชันนี้ไม่จัดการการยกเลิก Task เพื่อให้เกิด strong reference cycle
    func updateData7() {
        Task {
            self.data = await self.dataService.getData()
        }
        Task.detached {
            self.data = await self.dataService.getData()
        }
    }
    
    // MARK: ฟังก์ชันนี้ใช้ async/await เพื่ออัปเดตข้อมูลโดยตรงโดยไม่จำเป็นต้องใช้ Task.
    func updateData8() async {
        self.data = await self.dataService.getData()
    }

}

struct StrongSelfBootcamp: View {
    
    @StateObject private var viewModel = StrongSelfBootcampViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear {
                viewModel.updateData()
            }
            .onDisappear {
                viewModel.cancelTasks()
            }
            .task {
                await viewModel.updateData8()
            }
    }
}

#Preview {
    StrongSelfBootcamp()
}
