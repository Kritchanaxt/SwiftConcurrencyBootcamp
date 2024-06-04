//
//  SendableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: Sendable
/*
- เป็นโครงสร้างที่ใช้เพื่อระบุว่าประเภทข้อมูลนั้นสามารถส่งผ่าน concurrency context ระหว่าง threads หรือ tasks ได้โดยปลอดภัย
 - ซึ่งสิ่งนี้สำคัญเนื่องจากการเข้าถึงข้อมูลจากหลาย threads พร้อมกันอาจเป็นที่ปัญหา และ Sendable ช่วยในการรับรองว่าข้อมูลนั้นสามารถถูกส่งผ่านระบบ concurrency ได้โดยปลอดภัย
 */

import SwiftUI

// MARK: ประกาศตัวแปร CurrentUserManager เป็น actor
// ซึ่งเป็นโครงสร้างที่สามารถเก็บ state และป้องกันการแก้ไขข้อมูลที่มีการใช้งานจากส่วนอื่นพร้อมกันได้อย่างปลอดภัย
actor CurrentUserManager {
    
    // เป็นฟังก์ชันใน CurrentUserManager ที่ใช้สำหรับอัปเดตฐานข้อมูลโดยรับข้อมูลผู้ใช้จาก MyClassUserInfo
    func updateDatabase(userInfo: MyClassUserInfo) {
        
    }
    
}

// MARK: ประกาศโครงสร้าง MyUserInfo
// ซึ่งมี property เดียวคือ name โดยระบุว่า MyUserInfo เป็น Sendable
// ซึ่งหมายถึงสามารถส่งผ่านระหว่าง concurrency contexts ได้อย่างปลอดภัย
struct MyUserInfo: Sendable {
    var name: String
}

// MARK: ประกาศคลาส MyClassUserInfo
// ซึ่งเป็นคลาสที่มีการใช้งาน DispatchQueue เพื่อทำให้การอัปเดตข้อมูลเป็นแบบ asynchronous และระบุว่าเป็น Sendable โดยใช้ unchecked เพื่อระบุว่าสามารถส่งผ่านระหว่าง concurrency contexts ได้โดยไม่ต้องมีการตรวจสอบ
final class MyClassUserInfo: @unchecked Sendable {
    private var name: String
    let queue = DispatchQueue(label: "com.MyApp.MyClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

// MARK: เป็น ViewModel ที่ใช้สำหรับการอัปเดตข้อมูลผู้ใช้ปัจจุบัน
// ซึ่งมีฟังก์ชัน updateCurrentUserInfo() ที่ใช้สำหรับเรียกใช้งาน manager.updateDatabase(userInfo:) เพื่อทำการอัปเดตในฐานข้อมูล โดยใช้ async/await สำหรับการทำงานที่เป็น concurrency และรอการส่งผ่านค่าผ่านระหว่าง contexts อย่างปลอดภัย
class SendableBootcampViewModel: ObservableObject {
    
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        
        let info = MyClassUserInfo(name: "info")
        
        await manager.updateDatabase(userInfo: info)
    }
    
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text("Hello, World!")
            .task {
                
            }
    }
}

struct SendableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}

#Preview {
    SendableBootcamp()
}
