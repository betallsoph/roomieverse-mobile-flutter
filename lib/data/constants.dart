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

// ── Amenities ─────────────────────────────────────────────

// Roommate amenities (13 + other)
const roommateAmenityOptions = [
  'Điều hoà', 'WiFi', 'Máy giặt', 'Tủ lạnh', 'Bếp',
  'Gửi xe', 'Hồ bơi', 'Gym', 'Thang máy', 'Bảo vệ',
  'Ban công', 'Nội thất',
];

// Roomshare amenities (14 + other)
const roomshareAmenityOptions = [
  'Điều hoà', 'WiFi', 'Máy giặt', 'Tủ lạnh', 'Bếp',
  'Gửi xe', 'Hồ bơi', 'Gym', 'Thang máy', 'Bảo vệ',
  'Ban công', 'Nội thất', 'WC riêng',
];

// Short-term & sublease amenities (toggle buttons)
const simpleAmenityOptions = [
  ('ac', 'Điều hoà'),
  ('wifi', 'WiFi'),
  ('washing', 'Máy giặt'),
  ('fridge', 'Tủ lạnh'),
  ('kitchen', 'Bếp'),
  ('private-wc', 'WC riêng'),
  ('furnished', 'Nội thất'),
  ('parking', 'Gửi xe'),
  ('security', 'Bảo vệ'),
  ('elevator', 'Thang máy'),
];

// Keep old name for backward compatibility
const amenityOptions = roommateAmenityOptions;

// ── Property types ────────────────────────────────────────

// Full property types (roommate - single select)
const propertyTypeOptions = [
  ('apartment', 'Chung cư'),
  ('room', 'Phòng trọ'),
  ('service-apartment', 'Căn hộ dịch vụ'),
  ('dormitory', 'Ký túc xá'),
  ('house', 'Nhà nguyên căn'),
];

// Roomshare property types (binary toggle)
const roomsharePropertyTypes = [
  ('apartment', 'Chung cư'),
  ('house', 'Nhà'),
];

// ── Roommate type ─────────────────────────────────────────

const roommateTypeOptions = [
  ('have-room', 'Có phòng, tìm người ở cùng'),
  ('find-partner', 'Tìm phòng, tìm bạn ở ghép'),
];

// ── Preferences (ALL single-select to match web) ─────────

const genderOptions = [
  ('male', 'Nam'),
  ('female', 'Nữ'),
  ('any', 'Không quan tâm'),
];

const statusOptions = [
  ('student', 'Sinh viên'),
  ('working', 'Đi làm'),
  ('both', 'Cả hai'),
  ('other', 'Khác'),
];

const scheduleOptions = [
  ('early', 'Ngủ sớm, dậy sớm'),
  ('late', 'Cú đêm'),
  ('flexible', 'Linh hoạt'),
];

const cleanlinessOptions = [
  ('very-clean', 'Siêu sạch sẽ'),
  ('normal', 'Bình thường'),
  ('relaxed', 'Thoải mái'),
];

const habitOptions = [
  ('no-smoke', 'Không hút thuốc'),
  ('no-alcohol', 'Không rượu bia'),
  ('flexible', 'Linh hoạt'),
];

const petOptions = [
  ('no-pet', 'Không thú cưng'),
  ('pet-ok', 'Có thú cưng OK'),
  ('any', 'Không quan tâm'),
];

const moveInTimeOptions = [
  ('early-month', 'Đầu tháng'),
  ('end-month', 'Cuối tháng'),
  ('any', 'Bất kỳ'),
  ('asap', 'Càng sớm càng tốt'),
];

// ── Community post categories ─────────────────────────────

const communityCategories = [
  ('tips', 'Mẹo hay', 'Chia sẻ kinh nghiệm tìm phòng, ở ghép'),
  ('drama', 'Drama', 'Câu chuyện, tình huống thực tế'),
  ('review', 'Review', 'Đánh giá nơi ở, khu vực'),
  ('pass-do', 'Pass đồ', 'Chuyển nhượng đồ dùng'),
  ('blog', 'Blog', 'Bài viết dài, chia sẻ chuyên sâu'),
];

// ── Cost breakdown fields ─────────────────────────────────

// Full cost fields (used by roommate have-room in step 1 as total)
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

// Roomshare additional costs (step 3)
const roomshareCostFields = [
  ('electricity', 'Điện'),
  ('water', 'Nước'),
  ('internet', 'Internet'),
  ('service', 'Dịch vụ'),
  ('management', 'Quản lý'),
  ('parking', 'Gửi xe'),
  ('other', 'Khác'),
];

// ── Label lookup helpers ─────────────────────────────────

/// Get display label from a (value, label) option list
String? getOptionLabel(List<(String, String)> options, String? value) {
  if (value == null) return null;
  for (final opt in options) {
    if (opt.$1 == value) return opt.$2;
  }
  return value;
}

/// Get property type label
String? getPropertyTypeLabel(String? value) => getOptionLabel(propertyTypeOptions, value);
