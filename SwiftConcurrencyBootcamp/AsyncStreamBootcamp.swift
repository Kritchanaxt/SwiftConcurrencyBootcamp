//
//  AsyncStreamBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: AsyncThrowingStream ใช้เพื่อสร้างสตรีมข้อมูลแบบอะซิงโครนัสและจัดการข้อมูลใน ViewModel เพื่ออัปเดต UI ใน SwiftUI.

import SwiftUI

// สร้างคลาส AsyncStreamDataManager เพื่อจัดการข้อมูลที่ถูกสตรีมออกมา
class AsyncStreamDataManager {
    
    // ฟังก์ชัน getAsyncStream สร้าง AsyncThrowingStream ที่จะส่งค่าออกมาอย่างต่อเนื่องหรือส่ง error เมื่อเสร็จสิ้น
    func getAsyncStream() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { [weak self] continuation in
            self?.getFakeData(newValue: { value in
                continuation.yield(value)
            }, onFinish: { error in
                continuation.finish(throwing: error)
            })
        }
    }
    
    // ฟังก์ชัน getFakeData สร้างข้อมูลเป็นตัวเลขจาก 1 ถึง 10 โดยแต่ละค่าจะถูกส่งออกหลังจากเวลาที่กำหนด
    func getFakeData(
        newValue: @escaping (_ value: Int) -> Void,
        onFinish: @escaping (_ error: Error?) -> Void
    ) {
        let items: [Int] = [1,2,3,4,5,6,7,8,9,10]
        
        for item in items {
            
            // ใช้ DispatchQueue.main.asyncAfter เพื่อจำลองการส่งค่าข้อมูลทีละค่าหลังจากเวลาที่กำหนด
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item), execute: {
                newValue(item)
                print("New Data: \(item)")
                
                if item == items.last {
                    onFinish(nil)
                }
            })
        }
    }
    
}

// สร้างคลาส AsyncStreamViewModel ที่ conform กับ ObservableObject เพื่อใช้ใน SwiftUI และกำหนดให้ทำงานบน main thread ด้วย @MainActor
@MainActor
final class AsyncStreamViewModel : ObservableObject {
    
    // ประกาศ manager เพื่อเรียกใช้ฟังก์ชันใน AsyncStreamDataManager
    let manager = AsyncStreamDataManager()
    
    // ประกาศ @Published private(set) var currentNumber: Int = 0 เพื่อเก็บค่าข้อมูลปัจจุบันและอัปเดต UI เมื่อมีการเปลี่ยนแปลง
    @Published private(set) var currentNumber: Int = 0
    
    // ฟังก์ชัน onViewAppear เริ่มต้นการสตรีมข้อมูลและอัปเดต currentNumber เมื่อได้รับค่าข้อมูลใหม่
    func onViewAppear() {
//        manager.getFakeData { [weak self] value in
//            self?.currentNumber = value
//        }
        
        let task = Task {
            do {
                // ใช้ dropFirst(2) เพื่อข้ามค่าข้อมูล 2 ค่าแรก
                for try await value in manager.getAsyncStream().dropFirst(2) {
                    currentNumber = value
                }
            } catch {
                print(error)
            }
        }
        
        //ใช้ DispatchQueue.main.asyncAfter เพื่อยกเลิก task หลังจาก 5 วินาที
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            task.cancel()
            print("Task Canceled!")
        })
    }
    
}

struct AsyncStreamBootcamp: View {
    
    @StateObject private var viewModel = AsyncStreamViewModel()
    
    var body: some View {
        Text("\(viewModel.currentNumber)")
            .onAppear {
                viewModel.onViewAppear()
            }
    }
}

#Preview {
    AsyncStreamBootcamp()
}
