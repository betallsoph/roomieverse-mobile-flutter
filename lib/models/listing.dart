class RoommatePreferences {
  final List<String>? gender;
  final List<String>? status;
  final String? statusOther;
  final List<String>? schedule;
  final List<String>? cleanliness;
  final List<String>? habits;
  final List<String>? pets;
  final List<String>? moveInTime;
  final String? other;

  RoommatePreferences({
    this.gender,
    this.status,
    this.statusOther,
    this.schedule,
    this.cleanliness,
    this.habits,
    this.pets,
    this.moveInTime,
    this.other,
  });

  factory RoommatePreferences.fromJson(Map<String, dynamic> json) {
    return RoommatePreferences(
      gender: (json['gender'] as List?)?.cast<String>(),
      status: (json['status'] as List?)?.cast<String>(),
      statusOther: json['statusOther'] as String?,
      schedule: (json['schedule'] as List?)?.cast<String>(),
      cleanliness: (json['cleanliness'] as List?)?.cast<String>(),
      habits: (json['habits'] as List?)?.cast<String>(),
      pets: (json['pets'] as List?)?.cast<String>(),
      moveInTime: (json['moveInTime'] as List?)?.cast<String>(),
      other: json['other'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (gender != null) 'gender': gender,
        if (status != null) 'status': status,
        if (statusOther != null) 'statusOther': statusOther,
        if (schedule != null) 'schedule': schedule,
        if (cleanliness != null) 'cleanliness': cleanliness,
        if (habits != null) 'habits': habits,
        if (pets != null) 'pets': pets,
        if (moveInTime != null) 'moveInTime': moveInTime,
        if (other != null) 'other': other,
      };
}

class RoomCosts {
  final String? rent;
  final String? deposit;
  final String? electricity;
  final String? water;
  final String? internet;
  final String? service;
  final String? parking;
  final String? management;
  final String? other;

  RoomCosts({
    this.rent,
    this.deposit,
    this.electricity,
    this.water,
    this.internet,
    this.service,
    this.parking,
    this.management,
    this.other,
  });

  factory RoomCosts.fromJson(Map<String, dynamic> json) {
    return RoomCosts(
      rent: json['rent'] as String?,
      deposit: json['deposit'] as String?,
      electricity: json['electricity'] as String?,
      water: json['water'] as String?,
      internet: json['internet'] as String?,
      service: json['service'] as String?,
      parking: json['parking'] as String?,
      management: json['management'] as String?,
      other: json['other'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (rent != null) 'rent': rent,
        if (deposit != null) 'deposit': deposit,
        if (electricity != null) 'electricity': electricity,
        if (water != null) 'water': water,
        if (internet != null) 'internet': internet,
        if (service != null) 'service': service,
        if (parking != null) 'parking': parking,
        if (management != null) 'management': management,
        if (other != null) 'other': other,
      };
}

String _toStringOrEmpty(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  // Firestore Timestamp
  if (value.runtimeType.toString() == 'Timestamp') {
    return (value as dynamic).toDate().toIso8601String();
  }
  return value.toString();
}

String? _toStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value.runtimeType.toString() == 'Timestamp') {
    return (value as dynamic).toDate().toIso8601String();
  }
  return value.toString();
}

class RoomListing {
  final String id;
  final String title;
  final String author;
  final String price;
  final String location;
  final String? city;
  final String? district;
  final String? specificAddress;
  final String? addressOther;
  final String? buildingName;
  final bool? locationNegotiable;
  final String moveInDate;
  final bool? timeNegotiable;
  final String description;
  final List<String>? propertyTypes;
  final String phone;
  final String? zalo;
  final String? facebook;
  final String? instagram;
  final String postedDate;
  final String category;
  final String? roommateType;
  final String? propertyType;
  final String? image;
  final String? userId;
  final String? status;
  final String? introduction;
  final List<String>? images;
  final List<String>? amenities;
  final String? amenitiesOther;
  final RoommatePreferences? preferences;
  final RoomCosts? costs;
  final String? roomSize;
  final String? currentOccupants;
  final String? totalRooms;
  final String? othersIntro;
  final String? minContractDuration;
  final bool? isDraft;
  final String? createdAt;
  final String? updatedAt;
  final int? viewCount;
  final int? favoriteCount;

  RoomListing({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.location,
    this.city,
    this.district,
    this.specificAddress,
    this.addressOther,
    this.buildingName,
    this.locationNegotiable,
    required this.moveInDate,
    this.timeNegotiable,
    required this.description,
    this.propertyTypes,
    required this.phone,
    this.zalo,
    this.facebook,
    this.instagram,
    required this.postedDate,
    required this.category,
    this.roommateType,
    this.propertyType,
    this.image,
    this.userId,
    this.status,
    this.introduction,
    this.images,
    this.amenities,
    this.amenitiesOther,
    this.preferences,
    this.costs,
    this.roomSize,
    this.currentOccupants,
    this.totalRooms,
    this.othersIntro,
    this.minContractDuration,
    this.isDraft,
    this.createdAt,
    this.updatedAt,
    this.viewCount,
    this.favoriteCount,
  });

  factory RoomListing.fromJson(Map<String, dynamic> json, String docId) {
    return RoomListing(
      id: docId,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      price: _toStringOrEmpty(json['price']),
      location: json['location'] as String? ?? '',
      city: json['city'] as String?,
      district: json['district'] as String?,
      specificAddress: json['specificAddress'] as String?,
      addressOther: json['addressOther'] as String?,
      buildingName: json['buildingName'] as String?,
      locationNegotiable: json['locationNegotiable'] as bool?,
      moveInDate: _toStringOrEmpty(json['moveInDate']),
      timeNegotiable: json['timeNegotiable'] as bool?,
      description: json['description'] as String? ?? '',
      propertyTypes: (json['propertyTypes'] as List?)?.cast<String>(),
      phone: json['phone'] as String? ?? '',
      zalo: json['zalo'] as String?,
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      postedDate: _toStringOrEmpty(json['postedDate']),
      category: json['category'] as String? ?? '',
      roommateType: json['roommateType'] as String?,
      propertyType: json['propertyType'] as String?,
      image: json['image'] as String?,
      userId: json['userId'] as String?,
      status: json['status'] as String?,
      introduction: json['introduction'] as String?,
      images: (json['images'] as List?)?.cast<String>(),
      amenities: (json['amenities'] as List?)?.cast<String>(),
      amenitiesOther: json['amenitiesOther'] as String?,
      preferences: json['preferences'] != null
          ? RoommatePreferences.fromJson(
              json['preferences'] as Map<String, dynamic>)
          : null,
      costs: json['costs'] != null
          ? RoomCosts.fromJson(json['costs'] as Map<String, dynamic>)
          : null,
      roomSize: json['roomSize'] as String?,
      currentOccupants: json['currentOccupants'] as String?,
      totalRooms: json['totalRooms'] as String?,
      othersIntro: json['othersIntro'] as String?,
      minContractDuration: json['minContractDuration'] as String?,
      isDraft: json['isDraft'] as bool?,
      createdAt: _toStringOrNull(json['createdAt']),
      updatedAt: _toStringOrNull(json['updatedAt']),
      viewCount: json['viewCount'] as int?,
      favoriteCount: json['favoriteCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'author': author,
        'price': price,
        'location': location,
        if (city != null) 'city': city,
        if (district != null) 'district': district,
        if (specificAddress != null) 'specificAddress': specificAddress,
        if (addressOther != null) 'addressOther': addressOther,
        if (buildingName != null) 'buildingName': buildingName,
        if (locationNegotiable != null) 'locationNegotiable': locationNegotiable,
        'moveInDate': moveInDate,
        if (timeNegotiable != null) 'timeNegotiable': timeNegotiable,
        'description': description,
        if (propertyTypes != null) 'propertyTypes': propertyTypes,
        'phone': phone,
        if (zalo != null) 'zalo': zalo,
        if (facebook != null) 'facebook': facebook,
        if (instagram != null) 'instagram': instagram,
        'postedDate': postedDate,
        'category': category,
        if (roommateType != null) 'roommateType': roommateType,
        if (propertyType != null) 'propertyType': propertyType,
        if (image != null) 'image': image,
        if (userId != null) 'userId': userId,
        if (status != null) 'status': status,
        if (introduction != null) 'introduction': introduction,
        if (images != null) 'images': images,
        if (amenities != null) 'amenities': amenities,
        if (amenitiesOther != null) 'amenitiesOther': amenitiesOther,
        if (preferences != null) 'preferences': preferences!.toJson(),
        if (costs != null) 'costs': costs!.toJson(),
        if (roomSize != null) 'roomSize': roomSize,
        if (currentOccupants != null) 'currentOccupants': currentOccupants,
        if (totalRooms != null) 'totalRooms': totalRooms,
        if (othersIntro != null) 'othersIntro': othersIntro,
        if (minContractDuration != null) 'minContractDuration': minContractDuration,
        if (isDraft != null) 'isDraft': isDraft,
        'viewCount': viewCount ?? 0,
        'favoriteCount': favoriteCount ?? 0,
      };
}
