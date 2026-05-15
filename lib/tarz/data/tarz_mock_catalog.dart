import '../models/tarz_product_preview.dart';
import 'tarz_banner_assets.dart';

/// UI nümunəsi üçün statik məhsul siyahısı (API gələndə əvəz olunacaq).
abstract final class TarzMockCatalog {
  static const List<String> categories = [
    'Qadın',
    'Kişi',
    'Uşaq',
  ];

  static List<TarzProductPreview> trending() => const [
        TarzProductPreview(
          id: 't1',
          title: 'Yüksək bel denim',
          priceLabel: '89 AZN',
          badgeLabel: 'Yeni',
        ),
        TarzProductPreview(
          id: 't2',
          title: 'Minimal trikotaj sviter',
          priceLabel: '64 AZN',
        ),
        TarzProductPreview(
          id: 't3',
          title: 'Dəri kəmər',
          priceLabel: '42 AZN',
        ),
        TarzProductPreview(
          id: 't4',
          title: 'Klassik ağ köynək',
          priceLabel: '55 AZN',
        ),
      ];

  static List<TarzProductPreview> forYou() => const [
        TarzProductPreview(
          id: 'f1',
          title: 'Oversize palto',
          priceLabel: '210 AZN',
          badgeLabel: '-20%',
        ),
        TarzProductPreview(
          id: 'f2',
          title: 'Parlaq paltar',
          priceLabel: '175 AZN',
        ),
        TarzProductPreview(
          id: 'f3',
          title: 'İdman ayaqqabısı',
          priceLabel: '129 AZN',
        ),
        TarzProductPreview(
          id: 'f4',
          title: 'Çanta — krossbod',
          priceLabel: '98 AZN',
        ),
        TarzProductPreview(
          id: 'f5',
          title: 'Eynək — günəş',
          priceLabel: '72 AZN',
        ),
        TarzProductPreview(
          id: 'f6',
          title: 'Şal — kaşmir',
          priceLabel: '48 AZN',
        ),
      ];

  /// Ana səhifə — «Endirim» karuseli (dizayn nümunəsi).
  static List<TarzProductPreview> homeEndirim() => const [
        TarzProductPreview(
          id: 'he1',
          title: 'Nike V5 RNR',
          subtitle: 'İdman ayaqqabısı',
          priceLabel: '90₼',
          originalPriceLabel: '120₼',
          badgeLabel: '-25%',
          imageAsset: TarzBannerAssets.winter,
        ),
        TarzProductPreview(
          id: 'he2',
          title: 'Adidas Ultraboost',
          subtitle: 'İdman ayaqqabısı',
          priceLabel: '145₼',
          originalPriceLabel: '189₼',
          badgeLabel: '-23%',
          imageAsset: TarzBannerAssets.mehman,
        ),
        TarzProductPreview(
          id: 'he3',
          title: 'Puma RS-X',
          subtitle: 'Gündəlik',
          priceLabel: '76₼',
          originalPriceLabel: '110₼',
          badgeLabel: '-31%',
          imageAsset: TarzBannerAssets.yakup,
        ),
        TarzProductPreview(
          id: 'he4',
          title: 'New Balance 574',
          subtitle: 'Klassik',
          priceLabel: '99₼',
          originalPriceLabel: '130₼',
          badgeLabel: '-24%',
          imageAsset: TarzBannerAssets.tomy,
        ),
        TarzProductPreview(
          id: 'he5',
          title: 'Reebok Classic',
          subtitle: 'İdman ayaqqabısı',
          priceLabel: '65₼',
          originalPriceLabel: '85₼',
          badgeLabel: '-24%',
          imageAsset: TarzBannerAssets.aiTileSquare2,
        ),
      ];

  /// Ana səhifə — «Yenilər».
  static List<TarzProductPreview> homeYeniler() => const [
        TarzProductPreview(
          id: 'hy1',
          title: 'Minimal trikotaj',
          subtitle: 'Sviter',
          priceLabel: '64₼',
          badgeLabel: 'Yeni',
          imageAsset: TarzBannerAssets.mehman,
        ),
        TarzProductPreview(
          id: 'hy2',
          title: 'Yüksək bel denim',
          subtitle: 'Cins şalvar',
          priceLabel: '89₼',
          badgeLabel: 'Yeni',
          imageAsset: TarzBannerAssets.winter,
        ),
        TarzProductPreview(
          id: 'hy3',
          title: 'Oversize palto',
          subtitle: 'Qış',
          priceLabel: '210₼',
          badgeLabel: 'Yeni',
          imageAsset: TarzBannerAssets.yakup,
        ),
        TarzProductPreview(
          id: 'hy4',
          title: 'Krossbod çanta',
          subtitle: 'Aksesuar',
          priceLabel: '98₼',
          badgeLabel: 'Yeni',
          imageAsset: TarzBannerAssets.tomy,
        ),
      ];

  /// Ana səhifə — «Trendlər».
  static List<TarzProductPreview> homeTrendler() => const [
        TarzProductPreview(
          id: 'ht1',
          title: 'Parlaq axşam paltarı',
          subtitle: 'Don',
          priceLabel: '175₼',
          originalPriceLabel: '220₼',
          badgeLabel: '-20%',
          imageAsset: TarzBannerAssets.aiTileSquare2,
        ),
        TarzProductPreview(
          id: 'ht2',
          title: 'Kaşmir şal',
          subtitle: 'Aksesuar',
          priceLabel: '48₼',
          originalPriceLabel: '60₼',
          badgeLabel: '-20%',
          imageAsset: TarzBannerAssets.winter,
        ),
        TarzProductPreview(
          id: 'ht3',
          title: 'Günəş eynəyi',
          subtitle: 'Aksesuar',
          priceLabel: '72₼',
          badgeLabel: 'Top',
          imageAsset: TarzBannerAssets.mehman,
        ),
        TarzProductPreview(
          id: 'ht4',
          title: 'Dəri kəmər',
          subtitle: 'Kişi',
          priceLabel: '42₼',
          imageAsset: TarzBannerAssets.tomy,
        ),
      ];
}
