//
//  RefreshableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: Refreshable เป็นคุณสมบัติใหม่ของ SwiftUI ที่เปิดตัวใน iOS 15
// ช่วยให้สามารถทำให้ View รองรับการดึงเพื่อรีเฟรช (Pull to Refresh) ได้โดยง่าย คุณสมบัตินี้มักใช้กับ ScrollView เพื่อให้ผู้ใช้สามารถดึงหน้าจอลงมาเพื่อรีเฟรชเนื้อหาได้

import SwiftUI

//  ประกาศคลาสบริการข้อมูลที่ไม่สามารถถูก subclass ได้
final class RefreshableDataService {
    
    func getData() async throws -> [String] {
        // รอ 5 วินาที
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        // คืนค่ารายการผลไม้ที่ถูกสลับลำดับ
        return ["Apple", "Orange", "Banana"].shuffled()
    }
}

// ระบุว่าฟังก์ชันทั้งหมดในคลาสนี้จะทำงานบน Main Actor
@MainActor

// ประกาศ ViewModel ที่ไม่สามารถถูก subclass ได้ และสามารถประกาศการเปลี่ยนแปลงให้กับ SwiftUI
final class RefreshableBootcampViewModel: ObservableObject {
    
    // ประกาศตัวแปรที่เผยแพร่การเปลี่ยนแปลง แต่สามารถตั้งค่าได้เฉพาะภายในคลาสนี้
    @Published private(set) var items: [String] = []
    
    // สร้างอินสแตนซ์ของบริการข้อมูล
    let manager = RefreshableDataService()
    
    //  ฟังก์ชันแบบ async ที่ดึงข้อมูลจากบริการข้อมูลและจัดการข้อผิดพลาด
    func loadData() async {
        do {
            items = try await manager.getData()
        } catch {
            print(error)
        }
    }
}

struct RefreshableBootcamp: View {
    
    // สร้าง ViewModel ที่จะใช้ในการเชื่อมต่อข้อมูลกับ View
    @StateObject private var viewModel = RefreshableBootcampViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.items, id: \.self) { item in
                        Text(item)
                            .font(.headline)
                    }
                }
            }
            // เปิดใช้งานการดึงเพื่อรีเฟรช และเรียกฟังก์ชัน loadData เมื่อดึงเพื่อรีเฟรช
            .refreshable {
                await viewModel.loadData()
            }
            .navigationTitle("Refreshable")
            
            // เรียกฟังก์ชัน loadData เมื่อ View ปรากฏขึ้น
            .task {
                await viewModel.loadData()
            }
        }
    }
}

#Preview {
    RefreshableBootcamp()
}
