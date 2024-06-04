//
//  AsyncLetBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kritchanat on 4/6/2567 BE.
//

// MARK: async let ใช้งานเพื่อดาวน์โหลดและแสดงภาพจากอินเทอร์เน็ตพร้อมกันหลายภาพแบบ asynchronous ซึ่งช่วยเพิ่มประสิทธิภาพและลดเวลาในการรอการดาวน์โหลด โดยไม่ต้องรอดาวน์โหลดทีละภาพ

import SwiftUI

struct AsyncLetBootcamp: View {
    
    // ตัวแปรสำหรับเก็บภาพที่ดาวน์โหลดมา.
    @State private var images: [UIImage] = []
    
    // กำหนดรูปแบบการจัดเรียงภาพใน Grid แบบ 2 คอลัมน์.
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    //  URL ของภาพที่จะดาวน์โหลด.
    let url = URL(string: "https://picsum.photos/300")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                // แสดงภาพในรูปแบบ Grid.
                LazyVGrid(columns: columns) {
                    
                    // วนลูปแสดงผลภาพจากตัวแปร images.
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let 🥳")
            
            // เรียกใช้ Task เมื่อ view ปรากฏขึ้น.
            .onAppear {
                Task {
                    do {
                        
                        // สร้างงานแบบ asynchronous สำหรับการดาวน์โหลดภาพ.
                        async let fetchImage1 = fetchImage()
                        
                        // สร้างงานแบบ asynchronous สำหรับการดึงข้อมูล title.
                        async let fetchTitle1 = fetchTitle()
                        
                        // รอผลลัพธ์จากงานที่สร้างไว้.
                        let (image, title) = await (try fetchImage1, fetchTitle1)
                        
                        
                        // MARK: การดาวน์โหลดหลายภาพพร้อมกัน: โค้ดที่ถูกคอมเมนต์ไว้สามารถเปิดใช้เพื่อดาวน์โหลดหลายภาพพร้อมกัน.
//                        async let fetchImage2 = fetchImage()
//                        async let fetchImage3 = fetchImage()
//                        async let fetchImage4 = fetchImage()
//
//                        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
//                        self.images.append(contentsOf: [image1, image2, image3, image4])
                        
//                        let image1 = try await fetchImage()
//                        self.images.append(image1)
//
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
//
//                        let image4 = try await fetchImage()
//                        self.images.append(image4)

                    } catch {
                        
                    }
                }
            }
        }
    }
    
    // ฟังก์ชัน asynchronous สำหรับดึงข้อมูล title.
    func fetchTitle() async -> String {
        return "NEW TITLE"
    }
    
    // ฟังก์ชัน asynchronous สำหรับดาวน์โหลดภาพ, ซึ่งสามารถขว้างข้อผิดพลาดออกมาได้ (throws).
    func fetchImage() async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
    
    
}

struct AsyncLetBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLetBootcamp()
    }
}

#Preview {
    AsyncLetBootcamp()
}
