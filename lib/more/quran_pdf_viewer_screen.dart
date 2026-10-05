import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:qrn_app/data/quran_mushaf_pages.dart';

import 'package:qrn_app/services/quran_data_service.dart';
import 'package:qrn_app/services/quran_pdf_last_read_service.dart';

import 'package:qrn_app/translations.dart';

import 'package:qrn_app/widgets/more_page_scaffold.dart';

import 'package:qrn_app/widgets/mushaf_page_image.dart';



class QuranPdfViewerScreen extends StatefulWidget {

  final int initialPage;

  final bool isDarkMode;

  final String currentLanguage;

  final String? title;



  const QuranPdfViewerScreen({

    super.key,

    required this.initialPage,

    required this.isDarkMode,

    this.currentLanguage = 'English',

    this.title,

  });



  @override

  State<QuranPdfViewerScreen> createState() => _QuranPdfViewerScreenState();

}



class _QuranPdfViewerScreenState extends State<QuranPdfViewerScreen>

    with WidgetsBindingObserver {

  static const _primary = Color(0xFF1A5F4A);

  static const _gold = Color(0xFFC9A96E);



  late PageController _controller;

  late int _page;

  int _pageViewEpoch = 0;



  bool _verticalPages = true;

  bool _landscapeReading = false;



  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _page = clampCatalogPage(widget.initialPage);

    _controller = PageController(initialPage: catalogPageToViewerIndex(_page));

    SystemChrome.setPreferredOrientations([

      DeviceOrientation.portraitUp,

      DeviceOrientation.portraitDown,

      DeviceOrientation.landscapeLeft,

      DeviceOrientation.landscapeRight,

    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) => _persistLastRead());

  }



  @override

  void didChangeMetrics() {

    super.didChangeMetrics();

    if (mounted) setState(() {});

  }



  String _labelForPage(int catalogPage) {
    final n = mushafSurahNumberForPage(catalogPage);
    final svc = QuranDataService.instance;
    if (svc.isReady) {
      final surah = svc.surahByNumber(n);
      final name = surah?['surah_name_en']?.toString();
      if (name != null && name.isNotEmpty) return name;
    }
    if (widget.title != null &&
        widget.title!.isNotEmpty &&
        mushafPageForSurah(n) == catalogPage) {
      return widget.title!;
    }
    return 'Surah $n';
  }

  Future<void> _persistLastRead() async {
    if (!QuranDataService.instance.isReady) {
      await QuranDataService.instance.load();
    }
    await QuranPdfLastReadService.save(_page, _labelForPage(_page));
  }



  void _onPageChanged(int index) {

    setState(() => _page = viewerIndexToCatalogPage(index));

    _persistLastRead();

  }



  void _goToPage(int catalogPage) {

    final target = clampCatalogPage(catalogPage);

    _controller.jumpToPage(catalogPageToViewerIndex(target));

    setState(() => _page = target);

    _persistLastRead();

  }



  void _togglePageScrollDirection() {

    final index = catalogPageToViewerIndex(_page);

    final old = _controller;

    setState(() {

      _verticalPages = !_verticalPages;

      _controller = PageController(initialPage: index);

      _pageViewEpoch++;

    });

    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());

  }



  Future<void> _toggleLandscapeReading() async {

    final enable = !_landscapeReading;

    final pageIndex = catalogPageToViewerIndex(_page);



    if (enable) {

      await SystemChrome.setPreferredOrientations([

        DeviceOrientation.landscapeLeft,

        DeviceOrientation.landscapeRight,

      ]);

    } else {

      await SystemChrome.setPreferredOrientations([

        DeviceOrientation.portraitUp,

        DeviceOrientation.portraitDown,

      ]);

    }



    if (!mounted) return;



    final old = _controller;

    setState(() {

      _landscapeReading = enable;

      _controller = PageController(initialPage: pageIndex);

      _pageViewEpoch++;

    });

    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());

  }



  @override

  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    SystemChrome.setPreferredOrientations([

      DeviceOrientation.portraitUp,

      DeviceOrientation.portraitDown,

      DeviceOrientation.landscapeLeft,

      DeviceOrientation.landscapeRight,

    ]);

    _controller.dispose();

    super.dispose();

  }



  Widget _navFab({

    required IconData icon,

    required VoidCallback? onPressed,

  }) {

    return Material(

      color: _primary.withValues(alpha: 0.88),

      borderRadius: BorderRadius.circular(24),

      elevation: 2,

      child: InkWell(

        onTap: onPressed,

        borderRadius: BorderRadius.circular(24),

        child: SizedBox(

          width: 44,

          height: 44,

          child: Icon(icon, color: Colors.white, size: 28),

        ),

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    final pageLbl = Translations.getText(widget.currentLanguage, 'pageLabel');

    final getText = (String key) =>

        Translations.getText(widget.currentLanguage, key);



    return OrientationBuilder(

      builder: (context, orientation) {

        final landscapeLayout =

            _landscapeReading || orientation == Orientation.landscape;

        final canPrev = _page > kMushafCatalogFirstPage;

        final canNext = _page < kMushafCatalogLastPage;



        return MorePageScaffold(

          title: widget.title ?? getText('moreCardQuranPdf'),

          isDarkMode: widget.isDarkMode,

          currentLanguage: widget.currentLanguage,

          actions: [

            IconButton(

              tooltip: _verticalPages

                  ? getText('pdfScrollHorizontal')

                  : getText('pdfScrollVertical'),

              onPressed: _togglePageScrollDirection,

              icon: Icon(

                _verticalPages

                    ? Icons.view_column_outlined

                    : Icons.view_agenda_outlined,

              ),

            ),

            IconButton(

              tooltip: _landscapeReading

                  ? getText('pdfPortrait')

                  : getText('pdfLandscape'),

              onPressed: _toggleLandscapeReading,

              icon: Icon(

                _landscapeReading

                    ? Icons.stay_current_landscape

                    : Icons.screen_rotation_outlined,

                color: _landscapeReading ? _gold : Colors.white,

              ),

            ),

          ],

          body: Stack(

            children: [

              Positioned.fill(

                child: PageView.builder(

                  key: ValueKey('mushaf_pv_$_pageViewEpoch'),

                  controller: _controller,

                  scrollDirection:

                      _verticalPages ? Axis.vertical : Axis.horizontal,

                  itemCount: mushafCatalogPageCount,

                  onPageChanged: _onPageChanged,

                  itemBuilder: (context, index) {

                    final pageNum = viewerIndexToCatalogPage(index);

                    return MushafPageImage(

                      pageNumber: pageNum,

                      landscapeScrollReading: landscapeLayout,

                    );

                  },

                ),

              ),

              if (_verticalPages) ...[

                Positioned(

                  top: 8,

                  left: 0,

                  right: 0,

                  child: Center(

                    child: _navFab(

                      icon: Icons.keyboard_arrow_up_rounded,

                      onPressed: canPrev

                          ? () => _controller.previousPage(

                                duration: const Duration(milliseconds: 250),

                                curve: Curves.easeOut,

                              )

                          : null,

                    ),

                  ),

                ),

                Positioned(

                  bottom: 56,

                  left: 0,

                  right: 0,

                  child: Center(

                    child: _navFab(

                      icon: Icons.keyboard_arrow_down_rounded,

                      onPressed: canNext

                          ? () => _controller.nextPage(

                                duration: const Duration(milliseconds: 250),

                                curve: Curves.easeOut,

                              )

                          : null,

                    ),

                  ),

                ),

              ] else ...[

                Positioned(

                  left: 6,

                  top: 0,

                  bottom: 48,

                  child: Center(

                    child: _navFab(

                      icon: Icons.chevron_left_rounded,

                      onPressed: canPrev

                          ? () => _controller.previousPage(

                                duration: const Duration(milliseconds: 250),

                                curve: Curves.easeOut,

                              )

                          : null,

                    ),

                  ),

                ),

                Positioned(

                  right: 6,

                  top: 0,

                  bottom: 48,

                  child: Center(

                    child: _navFab(

                      icon: Icons.chevron_right_rounded,

                      onPressed: canNext

                          ? () => _controller.nextPage(

                                duration: const Duration(milliseconds: 250),

                                curve: Curves.easeOut,

                              )

                          : null,

                    ),

                  ),

                ),

              ],

              Positioned(

                left: 0,

                right: 0,

                bottom: 12,

                child: Center(

                  child: Material(

                    color: _primary.withValues(alpha: 0.9),

                    borderRadius: BorderRadius.circular(24),

                    child: InkWell(

                      onTap: () => _showGoToPageDialog(getText, pageLbl),

                      borderRadius: BorderRadius.circular(24),

                      child: Padding(

                        padding: const EdgeInsets.symmetric(

                          horizontal: 20,

                          vertical: 8,

                        ),

                        child: Text(

                          '$pageLbl $_page / $kMushafCatalogLastPage',

                          style: const TextStyle(

                            color: Colors.white,

                            fontWeight: FontWeight.w700,

                            fontSize: 13,

                          ),

                        ),

                      ),

                    ),

                  ),

                ),

              ),

            ],

          ),

        );

      },

    );

  }



  void _showGoToPageDialog(

    String Function(String) getText,

    String pageLbl,

  ) {

    final controller = TextEditingController(text: '$_page');

    showDialog<void>(

      context: context,

      builder: (context) => AlertDialog(

        title: Text(getText('pdfGoToPage')),

        content: TextField(

          controller: controller,

          keyboardType: TextInputType.number,

          textAlign: TextAlign.center,

          decoration: InputDecoration(

            hintText: pageLbl,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),

          ),

          onSubmitted: (value) {

            final p = int.tryParse(value);

            if (p != null &&

                p >= kMushafCatalogFirstPage &&

                p <= kMushafCatalogLastPage) {

              Navigator.pop(context);

              _goToPage(p);

            }

          },

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(context),

            child: Text(getText('cancel')),

          ),

        ],

      ),

    );

  }

}


