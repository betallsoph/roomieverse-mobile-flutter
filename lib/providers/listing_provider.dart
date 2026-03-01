import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/listing_service.dart';
import '../services/image_upload_service.dart';
import '../models/listing.dart';

final listingServiceProvider = Provider((ref) => ListingService());
final imageUploadServiceProvider = Provider((ref) => ImageUploadService());

final listingsProvider = FutureProvider<List<RoomListing>>((ref) async {
  return ref.watch(listingServiceProvider).getListings();
});

final listingsByCategoryProvider =
    FutureProvider.family<List<RoomListing>, String>((ref, category) async {
  return ref.watch(listingServiceProvider).getListingsByCategory(category);
});

final listingDetailProvider =
    FutureProvider.family<RoomListing?, String>((ref, id) async {
  return ref.watch(listingServiceProvider).getListingById(id);
});
