import '../models/banner_model.dart';
import '../models/benefit_model.dart';
import '../models/review.dart';
import 'banner_service.dart';
import 'benefit_service.dart';
import 'review_service.dart';

class HomeData {
  final List<BannerModel> banners;
  final List<BenefitModel> benefits;
  final List<Review> reviews;

  HomeData({
    required this.banners,
    required this.benefits,
    required this.reviews,
  });
}

class HomeService {
  static Future<HomeData> fetchHomeData() async {
    final results = await Future.wait([
      BannerService.fetchBanners(),
      BenefitService.fetchBenefits(),
      ReviewService.fetchReviews(),
    ]);
    return HomeData(
      banners: results[0] as List<BannerModel>,
      benefits: results[1] as List<BenefitModel>,
      reviews: results[2] as List<Review>,
    );
  }
}
