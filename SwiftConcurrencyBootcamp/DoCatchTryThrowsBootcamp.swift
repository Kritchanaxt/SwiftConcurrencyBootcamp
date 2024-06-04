//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: ใช้ do-catch, try, และ throws ในการจัดการข้อผิดพลาด และผลลัพธ์ที่อาจเกิดขึ้นจากการเรียกใช้ฟังก์ชันต่างๆ

import SwiftUI

// do-catch
// try
// throws

class DoCatchTryThrowsBootcampDataManager {
    
    // ตัวแปรเก็บสถานะว่าสมบัติ isActive เป็น true หรือ false
    let isActive: Bool = true
    
    // MARK: ฟังชั่นคืนค่าชื่อและข้อผิดพลาดในรูปแบบ tuple
    func getTitle() -> (title: String?, error: Error?) {
        
        // คืนชื่อเป็น "NEW TEXT!" ถ้า isActive เป็น true มิฉะนั้นคืน URLError ที่บ่งชี้ URL ไม่ถูกต้อง
        if isActive {
            return ("NEW TEXT!", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    // MARK: ฟังชั่นคืนค่าผลลัพธ์ในรูปแบบ Result
    func getTitle2() -> Result<String, Error> {
        
        // คืนค่าชื่อเป็น "NEW TEXT!" ถ้า isActive เป็น true มิฉะนั้นคืน URLError ที่บ่งชี้การเชื่อมต่อไม่ปลอดภัย
        if isActive {
            return .success("NEW TEXT!")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    func getTitle3() throws -> String {
//        if isActive {
//            return "NEW TEXT!"
//        } else {
        
            // โยนข้อผิดพลาด URLError ถ้า isActive เป็น false
            throw URLError(.badServerResponse)
//        }
    }
    
    func getTitle4() throws -> String {
        
        // คืนค่าชื่อเป็น "FINAL TEXT!" ถ้า isActive เป็น true มิฉะนั้นโยนข้อผิดพลาด URLError
        if isActive {
            return "FINAL TEXT!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject {
    
    // ตัวแปรเก็บข้อความที่จะแสดงใน SwiftUI View
    @Published var text: String = "Starting text."
    
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    // MARK: ฟังก์ชันนี้เป็นตัวอย่างการใช้ do-catch, try, และ throws สำหรับการจัดการข้อผิดพลาดจาก Data Manager
    func fetchTitle() {
        /*
        let returnedValue = manager.getTitle()
        
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
         */
        /*
        let result = manager.getTitle2()
        
        switch result {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
        */
        
        
//        let newTitle = try! manager.getTitle3()
//        self.text = newTitle

        // ใช้ do-catch เพื่อจับข้อผิดพลาดที่อาจเกิดขึ้น
        do {
            // ใช้ try? เพื่อรับค่าจาก getTitle3
            let newTitle = try? manager.getTitle3()
            if let newTitle = newTitle {
                self.text = newTitle
            }
            
            // ใช้ try เพื่อรับค่าจาก getTitle4 และจัดการข้อผิดพลาด
            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
        } catch {
            self.text = error.localizedDescription
        }
    }
}

struct DoCatchTryThrowsBootcamp: View {
    
    // ใช้งาน @StateObject เพื่อสร้างอินสแตนซ์ของ DoCatchTryThrowsBootcampViewModel
    @StateObject private var viewModel = DoCatchTryThrowsBootcampViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}


#Preview {
    DoCatchTryThrowsBootcamp()
}
