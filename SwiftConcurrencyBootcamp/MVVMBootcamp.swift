//
//  MVVMBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//


import SwiftUI

// คลาสที่ใช้ในการจัดการข้อมูล
final class MyManagerClass {
    // ฟังก์ชันแบบอะซิงโครนัสที่คืนค่าเป็น String
    func getData() async throws -> String {
        "Some Data!"
    }
}

// Actor ที่ใช้ในการจัดการข้อมูล
actor MyManagerActor {
    // ฟังก์ชันแบบอะซิงโครนัสที่คืนค่าเป็น String
    func getData() async throws -> String {
        "Some Data!"
    }
}

// ViewModel ที่ทำงานใน MainActor
@MainActor
final class MVVMBootcampViewModel: ObservableObject {
    
    // อินสแตนซ์ของ MyManagerClass และ MyManagerActor
    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()
    
    // ตัวแปรที่ Published เพื่อใช้ใน View
    @Published private(set) var myData: String = "Starting text"
    
    // อาเรย์สำหรับเก็บ Task
    private var tasks: [Task<Void, Never>] = []
    
    // ฟังก์ชันสำหรับยกเลิก Task ทั้งหมด
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    // ฟังก์ชันที่ถูกเรียกเมื่อปุ่มถูกกด
    func onCallToActionButtonPressed() {
        // สร้าง Task ใหม่
        let task = Task {
            do {
                // เรียกใช้งานฟังก์ชัน getData จาก MyManagerActor
                myData = try await managerActor.getData()
            } catch {
                print(error)
            }
        }
        // เพิ่ม Task ใหม่ในอาเรย์ tasks
        tasks.append(task)
    }
}


struct MVVMBootcamp: View {
    
    @StateObject private var viewModel = MVVMBootcampViewModel()
    
    var body: some View {
        VStack {
            Button(viewModel.myData) {
                viewModel.onCallToActionButtonPressed()
            }
        }
        .onDisappear {
            
        }
    }
}

#Preview {
    MVVMBootcamp()
}
