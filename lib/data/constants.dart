// Cities, districts, amenities, and option maps
// Matching web project /app/data/locations.ts

class District {
  final String value;
  final String label;
  const District({required this.value, required this.label});
}

class City {
  final String value;
  final String label;
  final List<District> districts;
  const City({required this.value, required this.label, required this.districts});
}

const cities = <City>[
  City(
    value: 'ho-chi-minh',
    label: 'TP. Hồ Chí Minh',
    districts: [
      District(value: 'quan-1', label: 'Quận 1'),
      District(value: 'quan-2', label: 'Quận 2'),
      District(value: 'quan-3', label: 'Quận 3'),
      District(value: 'quan-4', label: 'Quận 4'),
      District(value: 'quan-5', label: 'Quận 5'),
      District(value: 'quan-6', label: 'Quận 6'),
      District(value: 'quan-7', label: 'Quận 7'),
      District(value: 'quan-8', label: 'Quận 8'),
      District(value: 'quan-9', label: 'Quận 9'),
      District(value: 'quan-10', label: 'Quận 10'),
      District(value: 'quan-11', label: 'Quận 11'),
      District(value: 'quan-12', label: 'Quận 12'),
      District(value: 'binh-tan', label: 'Bình Tân'),
      District(value: 'binh-thanh', label: 'Bình Thạnh'),
      District(value: 'go-vap', label: 'Gò Vấp'),
      District(value: 'phu-nhuan', label: 'Phú Nhuận'),
      District(value: 'tan-binh', label: 'Tân Bình'),
      District(value: 'tan-phu', label: 'Tân Phú'),
      District(value: 'thu-duc', label: 'Thủ Đức'),
      District(value: 'binh-chanh', label: 'Bình Chánh'),
      District(value: 'can-gio', label: 'Cần Giờ'),
      District(value: 'cu-chi', label: 'Củ Chi'),
      District(value: 'hoc-mon', label: 'Hóc Môn'),
      District(value: 'nha-be', label: 'Nhà Bè'),
    ],
  ),
  City(
    value: 'da-lat',
    label: 'Đà Lạt',
    districts: [
      District(value: 'phuong-1', label: 'Phường 1'),
      District(value: 'phuong-2', label: 'Phường 2'),
      District(value: 'phuong-3', label: 'Phường 3'),
      District(value: 'phuong-4', label: 'Phường 4'),
      District(value: 'phuong-5', label: 'Phường 5'),
      District(value: 'phuong-6', label: 'Phường 6'),
      District(value: 'phuong-7', label: 'Phường 7'),
      District(value: 'phuong-8', label: 'Phường 8'),
      District(value: 'phuong-9', label: 'Phường 9'),
      District(value: 'phuong-10', label: 'Phường 10'),
      District(value: 'phuong-11', label: 'Phường 11'),
      District(value: 'phuong-12', label: 'Phường 12'),
      District(value: 'xuan-tho', label: 'Xuân Thọ'),
      District(value: 'xuan-truong', label: 'Xuân Trường'),
      District(value: 'ta-nung', label: 'Tà Nung'),
      District(value: 'tram-hanh', label: 'Trạm Hành'),
    ],
  ),
];

List<District> getDistrictsByCity(String cityValue) {
  for (final city in cities) {
    if (city.value == cityValue) return city.districts;
  }
  return [];
}

String? getCityLabel(String? cityValue) {
  if (cityValue == null) return null;
  for (final city in cities) {
    if (city.value == cityValue) return city.label;
  }
  return cityValue;
}

String? getDistrictLabel(String? cityValue, String? districtValue) {
  if (cityValue == null || districtValue == null) return null;
  for (final city in cities) {
    if (city.value == cityValue) {
      for (final d in city.districts) {
        if (d.value == districtValue) return d.label;
      }
    }
  }
  return districtValue;
}

// Amenities
const amenityOptions = [
  'Điều hoà',
  'WiFi',
  'Máy giặt',
  'Tủ lạnh',
  'Nóng lạnh',
  'Ban công',
  'Bếp',
  'Gửi xe',
  'Bảo vệ',
  'Thú cưng OK',
  'Nội thất',
];

// Property types
const propertyTypeOptions = [
  ('house', 'Nhà'),
  ('apartment', 'Chung cư'),
];

// Roommate type
const roommateTypeOptions = [
  ('have-room', 'Có phòng, tìm người ở cùng'),
  ('find-partner', 'Tìm phòng, tìm bạn ở ghép'),
];

// Gender preferences
const genderOptions = [
  ('male', 'Nam'),
  ('female', 'Nữ'),
  ('any', 'Không quan tâm'),
];

// Status preferences
const statusOptions = [
  ('student', 'Sinh viên'),
  ('working', 'Đi làm'),
  ('freelancer', 'Freelancer'),
  ('other', 'Khác'),
];

// Schedule preferences
const scheduleOptions = [
  ('early', 'Ngủ sớm, dậy sớm'),
  ('late', 'Cú đêm'),
  ('flexible', 'Linh hoạt'),
];

// Cleanliness labels (0-3 slider)
const cleanlinessLabels = [
  'Bừa bộn',
  'Thoải mái',
  'Bình thường',
  'Siêu sạch sẽ',
];

const cleanlinessValues = [
  'messy',
  'relaxed',
  'normal',
  'very-clean',
];

// Habits
const habitOptions = [
  ('smoke', 'Hút thuốc'),
  ('drink', 'Uống rượu bia'),
  ('loud', 'Ồn ào, hay mở nhạc'),
  ('quiet', 'Yên lặng'),
  ('gamer', 'Hay chơi game'),
  ('long-shower', 'Tắm lâu'),
  ('cook', 'Hay nấu ăn'),
  ('wfh', 'Làm việc tại nhà'),
  ('invite-friends', 'Hay mời bạn về chơi'),
  ('introvert', 'Thích ở một mình'),
];

// Pet preferences
const petOptions = [
  ('has-pet', 'Đang nuôi thú cưng'),
  ('want-pet', 'Muốn nuôi thú cưng'),
  ('no-pet', 'Không nuôi thú cưng'),
  ('pet-allergy', 'Dị ứng lông thú cưng'),
];

// Move-in time
const moveInTimeOptions = [
  ('asap', 'Càng sớm càng tốt'),
  ('this-month', 'Trong tháng này'),
  ('next-month', 'Tháng sau'),
  ('flexible', 'Linh hoạt'),
];

// Community post categories
const communityCategories = [
  ('tips', 'Mẹo hay', 'Chia sẻ kinh nghiệm tìm phòng, ở ghép'),
  ('drama', 'Drama', 'Câu chuyện, tình huống thực tế'),
  ('review', 'Review', 'Đánh giá nơi ở, khu vực'),
  ('pass-do', 'Pass đồ', 'Chuyển nhượng đồ dùng'),
  ('blog', 'Blog', 'Bài viết dài, chia sẻ chuyên sâu'),
];

// Cost breakdown fields
const costFields = [
  ('rent', 'Tiền phòng'),
  ('deposit', 'Tiền cọc'),
  ('electricity', 'Điện'),
  ('water', 'Nước'),
  ('internet', 'Internet'),
  ('service', 'Dịch vụ'),
  ('parking', 'Gửi xe'),
  ('management', 'Quản lý'),
  ('other', 'Khác'),
];
