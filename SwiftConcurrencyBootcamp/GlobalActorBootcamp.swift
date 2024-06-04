//
//  GlobalActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: @globalActor
/*
 - เป็นอ็อกเจ็กต์ใหม่ที่ใช้ในการกำหนดลักษณะของ global actor
 - เพื่อการจัดการข้อมูลที่เปลี่ยนแปลงได้แบบ concurrent ในระบบ iOS, macOS, watchOS, และ tvOS
 - ทำให้สามารถกำหนด behavior ของ global actor ได้อย่างมีประสิทธิภาพ
 - โดย @globalActor สามารถกำหนด behavior ที่ต้องการเพื่อให้สามารถเข้าถึงหรือประมวลผลข้อมูลที่ต้องการสำหรับหลาย thread ได้อย่างปลอดภัย
 */

import SwiftUI

// MARK: ประกาศคลาส MyFirstGlobalActor
// โดยใช้ @globalActor เพื่อสร้างตัวกำหนดการเข้าถึงข้อมูลแบบ global และเป็น final เพื่อไม่ให้สามารถสืบทอดได้
@globalActor final class MyFirstGlobalActor {
    
    // สร้างตัวแปร shared ภายใน MyFirstGlobalActor เพื่อใช้แบ่งปันตัวจัดการข้อมูลให้กับโมดูลอื่น ๆ
    static var shared = MyNewDataManager()
    
}

// MARK: ประกาศ actor MyNewDataManager ซึ่งจะใช้ในการจัดการข้อมูล
actor MyNewDataManager {
    
    // สร้างเมทอด getDataFromDatabase() ภายใน MyNewDataManager เพื่อจำลองการเรียกข้อมูลจากฐานข้อมูล
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five", "Six"]
    }
    
}

//@MainActor
class GlobalActorBootcampViewModel: ObservableObject {
    
    // ประกาศตัวแปร dataArray ที่เป็น Published และถูกติดป้ายกำกับด้วย @MainActor เพื่อให้สามารถอัพเดต UI ได้บนเธรดหลัก
    @MainActor @Published var dataArray: [String] = []
//    @Published var dataArray1: [String] = []
//    @Published var dataArray2: [String] = []
//    @Published var dataArray3: [String] = []
//    @Published var dataArray4: [String] = []
    
    // สร้างตัวแปร manager เพื่อเข้าถึงตัวจัดการข้อมูล MyNewDataManager ผ่าน MyFirstGlobalActor.shared
    let manager = MyFirstGlobalActor.shared
    
    
    //    nonisolated
    // ประกาศเมทอด getData() ที่ถูกยึดจากตัวกำหนดการเข้าถึงข้อมูลแบบ global MyFirstGlobalActor เพื่อให้สามารถเข้าถึงข้อมูลได้
    @MyFirstGlobalActor func getData() {
        
        // HEAVY COMPLEX METHODS
        
        //  ใช้ Task เพื่อเรียกใช้ getDataFromDatabase() และอัพเดต dataArray โดยใช้ MainActor.run เพื่ออัพเดต UI บนเธรดหลัก
        Task {
            let data = await manager.getDataFromDatabase()
            await MainActor.run(body: {
                self.dataArray = data
            })
        }
    }
    
}

struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    
                    // ใช้ค่า `$0` ซึ่งอ้างถึงข้อมูลของแต่ละ element ใน collection หรือ array ที่ถูก loop ด้วย `ForEach` ในที่นี้คือ array `viewModel.dataArray`
                    //ซึ่งใช้เพื่อแสดงข้อความตามค่าข้อมูลในแต่ละ element ของ array นั้นๆ ที่ถูก loop อยู่ ในส่วนนี้ `$0` จะแทนค่าของแต่ละ element ใน loop นั้นๆ ครับ
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
    
}

#Preview {
    GlobalActorBootcamp()
}
