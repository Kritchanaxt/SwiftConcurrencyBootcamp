//
//  ObservableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: @Observable (ซึ่งใช้ใน SwiftUI) ทำหน้าที่ช่วยให้ View
// สามารถสังเกตและตอบสนองต่อการเปลี่ยนแปลงของข้อมูลได้อัตโนมัติ.
// แม้ว่าจะไม่ได้มีชื่อเป็น @Observable โดยตรง แต่ใน SwiftUI เราใช้โปรโตคอล ObservableObject และ property wrapper @Published เพื่อจัดการกับการสังเกตการเปลี่ยนแปลงข้อมูล.

import SwiftUI

// MARK: การประกาศ actor ชื่อ TitleDatabase เพื่อสร้าง concurrent object ที่สามารถทำงาน asynchronous ได้
actor TitleDatabase {
    
    // MARK: ประกาศฟังก์ชัน getNewTitle() เพื่อดึงข้อมูลชื่อใหม่จากฐานข้อมูล และคืนค่าเป็น String
    func getNewTitle() -> String {
        
        // ค่าคืนของฟังก์ชัน getNewTitle() ซึ่งเป็นข้อมูลชื่อใหม่ที่จะถูกสร้างขึ้น
        "Some new title!"
    }
}
    
// MARK: ประกาศคลาส ObservableViewModel โดยใช้ decorator @Observable
// เพื่อระบุว่าคลาสนี้เป็น Observable object ที่สามารถติดตามการเปลี่ยนแปลงข้อมูลได้
@Observable class ObservableViewModel {
    
    // MARK: ประกาศตัวแปร database ซึ่งมีประเภทเป็น TitleDatabase
    // ซึ่งจะถูกใช้ในการเรียกใช้งานข้อมูล แต่การเปลี่ยนแปลงของข้อมูลในตัวแปรนี้จะไม่ถูกสังเกตการเปลี่ยนแปลง (ignored) โดยอัตโนมัติ
    @ObservationIgnored let database = TitleDatabase()
    
   // ใช้ @MainActor decorator เพื่อระบุว่าการเปลี่ยนแปลงของ title จะต้องเกิดขึ้นบน Main Actor เท่านั้น และกำหนดค่าเริ่มต้นของ title เป็น "Starting title"
    @MainActor var title: String = "Starting title"
    
    func updateTitle() {
        
        // สร้าง Task ภายในฟังก์ชัน โดยกำหนดให้ประมวลผลภายใน Task เกิดขึ้นบน Main Actor ด้วย @MainActor
        Task { @MainActor in
            
            // กำหนดค่าของ title ใช้ค่าที่ได้จากการเรียกใช้งาน getNewTitle() ของ database
            // ซึ่งเป็นการเรียกใช้งาน asynchronous และใช้ await เพื่อรอข้อมูลก่อนที่จะดำเนินการต่อ
            title = await database.getNewTitle()
            
            // พิมพ์ Thread ปัจจุบันที่ใช้งานอยู่ ซึ่งเป็นการตรวจสอบ Thread ที่ Task กำลังทำงานอยู่
            print(Thread.current)
        }
    }
}

struct ObservableBootcamp: View {
    
    @State private var viewModel = ObservableViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .onAppear {
                viewModel.updateTitle()
            }
    }
}


#Preview {
    ObservableBootcamp()
}
