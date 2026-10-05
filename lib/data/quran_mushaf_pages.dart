// Sunnahsource mushaf catalog (Bolton pattern): PNG pages 4–852.
// URLs: https://…/quran/page0006.png (no slash before page number).

const int kMushafCatalogFirstPage = 4;
const int kMushafCatalogLastPage = 852;

/// First catalog page for each surah (1–114).
const List<int> kMushafStartPageBySurah = [
  6,
  7,
  72,
  110,
  151,
  181,
  213,
  250,
  264,
  292,
  312,
  332,
  350,
  359,
  368,
  376,
  397,
  412,
  429,
  439,
  453,
  466,
  481,
  491,
  505,
  515,
  529,
  541,
  556,
  566,
  575,
  581,
  585,
  599,
  607,
  615,
  622,
  632,
  639,
  651,
  663,
  672,
  681,
  690,
  695,
  701,
  708,
  714,
  720,
  725,
  729,
  733,
  736,
  740,
  744,
  749,
  754,
  761,
  765,
  770,
  774,
  777,
  779,
  781,
  784,
  787,
  791,
  794,
  798,
  801,
  804,
  807,
  810,
  812,
  815,
  817,
  820,
  823,
  824,
  826,
  828,
  829,
  830,
  832,
  833,
  834,
  835,
  836,
  837,
  839,
  840,
  841,
  842,
  842,
  843,
  843,
  844,
  844,
  845,
  846,
  846,
  847,
  847,
  848,
  848,
  848,
  849,
  849,
  850,
  850,
  850,
  851,
  851,
  851,
  852,
];

int mushafPageForSurah(int surahNumber) {
  if (surahNumber < 1 || surahNumber > 114) return kMushafCatalogFirstPage;
  return kMushafStartPageBySurah[surahNumber - 1];
}

/// Surah (1–114) that contains this mushaf catalog page.
int mushafSurahNumberForPage(int page) {
  final p = clampCatalogPage(page);
  var surah = 1;
  for (var i = 0; i < kMushafStartPageBySurah.length; i++) {
    if (kMushafStartPageBySurah[i] <= p) {
      surah = i + 1;
    }
  }
  return surah;
}

int clampCatalogPage(int page) =>
    page.clamp(kMushafCatalogFirstPage, kMushafCatalogLastPage);

List<String> mushafPageImageUrls(int page) {
  final catalog = clampCatalogPage(page);
  final p = catalog.toString().padLeft(4, '0');
  return [
    'https://tushroomsinternetlab.sunnahsource.org/quran/page$p.png',
    'https://cdn.sunnahsource.org/quran/page$p.png',
    'https://www.sunnahsource.org/quran/page$p.png',
  ];
}

String mushafPageImageUrl(int page) => mushafPageImageUrls(page).first;

int catalogPageToViewerIndex(int catalogPage) =>
    clampCatalogPage(catalogPage) - kMushafCatalogFirstPage;

int viewerIndexToCatalogPage(int index) =>
    clampCatalogPage(kMushafCatalogFirstPage + index);

int get mushafCatalogPageCount =>
    kMushafCatalogLastPage - kMushafCatalogFirstPage + 1;
