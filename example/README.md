# ip_address_plugin_example

Ví dụ minh họa cách sử dụng plugin `ip_address_plugin` để:

- Lấy địa chỉ **IPv4 / IPv6** trên Android và iOS.  
- Chọn loại mạng **Wi‑Fi** hoặc **Mobile Data** khi lấy IP.  
- Kiểm tra và hiển thị thông báo **"No internet connection"** khi thiết bị offline hoặc không có kết nối mạng phù hợp.

## Cấu trúc

- Thư mục này là một ứng dụng Flutter độc lập dùng để demo plugin.  
- Plugin được khai báo như một dependency trong `pubspec.yaml` (dưới dạng `path` tới thư mục plugin hoặc version từ pub.dev).  
- Màn hình chính chứa UI đơn giản để:
  - Chọn loại mạng cần lấy IP.  
  - Gọi hàm từ `ip_address_plugin`.  
  - Hiển thị kết quả IP hoặc thông báo lỗi thân thiện.

## Hướng dẫn chạy

1. **Di chuyển vào thư mục example** (từ root của repo plugin):

   
   cd example
   

2. **Cài đặt phụ thuộc**:

  
   flutter pub get
 

3. **Chạy ứng dụng trên thiết bị / emulator**:


   flutter run


4. **Trên ứng dụng ví dụ**:
   - Chọn loại mạng (Wi‑Fi / Mobile Data).  
   - Nhấn nút để lấy IP.  
     - IP trả về (IPv4/IPv6) nếu có kết nối.  
     - Chuỗi **"No internet connection"** nếu không có mạng.

## Ghi chú

- Đảm bảo thiết bị / emulator có quyền truy cập mạng.  
- Nếu chạy trên iOS, cần mở dự án trong Xcode và cấu hình các quyền, team, bundle id… như các dự án iOS thông thường nếu có yêu cầu thêm.
