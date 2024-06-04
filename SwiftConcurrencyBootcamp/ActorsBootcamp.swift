//
//  ActorsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: actor
// เป็นรูปแบบของชนิดข้อมูลที่เป็น thread-safe ซึ่งใช้สำหรับจัดการการเปลี่ยนแปลงของข้อมูลในสภาพแวดล้อมที่มีการใช้งานหลาย thread หรือการทำงานแบบ concurrent เหมือนกับ Class แต่ปลอดภัยต่อเธรด!

// MARK: nonisolated
// เป็นคุณลักษณะที่ใช้ใน context ของ actors เพื่อระบุว่าเมธอดหรือพร็อพเพอร์ตี้สามารถเข้าถึงได้
// โดยไม่ต้องอยู่ในขอบเขตการแยกตัว (isolation context) ของ actor นั้นๆ กล่าวคือ ไม่ต้องการการประสาน (synchronization) ที่จัดการโดย actor

// MARK: ทำไมถึงใช้ nonisolated เพื่อรับประกันความปลอดภัยของข้อมูลและการจัดการ concurrent อย่างถูกต้อง

import SwiftUI

class MyDataManager {
    
    // สร้าง instance เดียวของคลาส
    static let instance = MyDataManager()
    
    // กำหนดให้ initializer เป็น private เพื่อป้องกันการสร้าง instance ใหม่
    private init() { }
    
    // ตัวแปรเก็บข้อมูลเป็น array ของ String
    var data: [String] = []
    
    // สร้างคิวสำหรับการล็อคเพื่อป้องกันการเข้าถึงข้อมูลพร้อมกันจากหลายเธรด
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    // ฟังก์ชันสำหรับเพิ่มข้อมูลใหม่และสุ่มข้อมูลจาก data array โดยใช้คิวล็อคเพื่อความปลอดภัยใน multi-threading
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
    
}

// actor ใช้สำหรับการจัดการข้อมูลแบบ concurrency ปลอดภัยใน Swift
actor MyActorDataManager {
    
    // สร้าง instance เดียวของ actor
    static let instance = MyActorDataManager()
    
    // กำหนดให้ initializer เป็น private เพื่อป้องกันการสร้าง instance ใหม่
    private init() { }
    
    // ตัวแปรเก็บข้อมูลเป็น array ของ String
    var data: [String] = []
    
    // กำหนดตัวแปรแบบ nonisolated ซึ่งไม่ถูกจัดการโดย actor
    nonisolated let myRandomText = "asdfasdfadfsfdsdfs"
    
    // ฟังก์ชันสำหรับเพิ่มข้อมูลใหม่และสุ่มข้อมูลจาก data array
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    // ฟังก์ชันแบบ nonisolated สำหรับคืนค่าข้อมูล
    nonisolated func getSavedData() -> String {
        return "NEW DATA"
    }
    
}


struct HomeView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    
    // สร้างตัวจับเวลา (timer) ที่จะทำงานทุก 0.1 วินาที
    let timer = Timer.publish(every: 0.1, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear(perform: {
            // เข้าถึงตัวแปร myRandomText ของ manager
            let newString = manager.myRandomText
            
            // ใช้ async task เพื่อเรียกฟังก์ชัน getSavedData()
            Task {
                let newString = await manager.getSavedData()
            }
        })
        
        // เรียกใช้เมื่อ timer ทำงาน
        .onReceive(timer) { _ in
            Task {
                
                // ตรวจสอบว่ามีข้อมูลจาก getRandomData() หรือไม่
                if let data = await manager.getRandomData() {
                    
                    // อัปเดตตัวแปร text บน main thread
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()

    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
        }
    }
}

struct ActorsBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorsBootcamp()
}
