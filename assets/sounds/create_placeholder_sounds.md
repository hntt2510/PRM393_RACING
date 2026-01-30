# Hướng dẫn tạo file âm thanh placeholder

Nếu bạn chưa có file âm thanh, bạn có thể tạo các file placeholder đơn giản bằng cách:

## Cách 1: Sử dụng online sound generator

1. Truy cập: flu
2. Tạo các tone đơn giản:
   - **betting.mp3**: Tone 440Hz, duration 2s (âm thanh nhẹ nhàng)
   - **race.mp3**: Tone 200Hz với modulation, duration 5s (âm thanh rung động như ngựa chạy)
   - **win.mp3**: Tone ascending 440Hz-880Hz, duration 1s (âm thanh tăng dần)
   - **lose.mp3**: Tone descending 880Hz-220Hz, duration 1s (âm thanh giảm dần)
   - **summary.mp3**: Tone 330Hz, duration 3s (âm thanh trung tính)

## Cách 2: Tải từ các nguồn miễn phí

### Betting Sound:
- https://freesound.org/search/?q=betting+casino
- https://mixkit.co/free-sound-effects/casino/

### Race Sound (Horse Galloping):
- https://freesound.org/search/?q=horse+galloping
- https://mixkit.co/free-sound-effects/horse/

### Win Sound:
- https://freesound.org/search/?q=win+victory+cheer
- https://mixkit.co/free-sound-effects/victory/

### Lose Sound:
- https://freesound.org/search/?q=lose+fail+sad
- https://mixkit.co/free-sound-effects/fail/

### Summary Sound:
- https://freesound.org/search/?q=summary+statistics
- https://mixkit.co/free-sound-effects/notification/

## Cách 3: Sử dụng Audacity (miễn phí)

1. Tải Audacity: https://www.audacityteam.org/
2. Tạo tone: Generate > Tone
3. Export: File > Export > Export as MP3

## Lưu ý

- File phải có định dạng MP3 hoặc WAV
- Đặt tên file chính xác: betting.mp3, race.mp3, win.mp3, lose.mp3, summary.mp3
- Đặt trong thư mục `assets/sounds/`
- Game sẽ hoạt động bình thường ngay cả khi không có file âm thanh (chỉ không có sound)
