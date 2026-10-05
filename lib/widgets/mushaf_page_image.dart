import 'package:flutter/material.dart';

import 'package:qrn_app/data/quran_mushaf_pages.dart';



/// Network mushaf page with CDN fallbacks (Bolton / sunnahsource pattern).

class MushafPageImage extends StatefulWidget {

  final int pageNumber;



  /// Bolton-style landscape: page fills width, scroll vertically to read.

  final bool landscapeScrollReading;



  const MushafPageImage({

    super.key,

    required this.pageNumber,

    this.landscapeScrollReading = false,

  });



  @override

  State<MushafPageImage> createState() => _MushafPageImageState();

}



class _MushafPageImageState extends State<MushafPageImage> {

  int _urlIndex = 0;



  @override

  void didUpdateWidget(MushafPageImage oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (oldWidget.pageNumber != widget.pageNumber) {

      _urlIndex = 0;

    }

  }



  void _tryNextUrl() {

    final urls = mushafPageImageUrls(widget.pageNumber);

    if (_urlIndex + 1 < urls.length) {

      setState(() => _urlIndex++);

    }

  }



  Widget _networkImage({

    required BoxFit fit,

    required double? width,

    required double? height,

    required Alignment alignment,

  }) {

    final urls = mushafPageImageUrls(widget.pageNumber);

    final url = urls[_urlIndex.clamp(0, urls.length - 1)];



    return Image.network(

      url,

      fit: fit,

      width: width,

      height: height,

      alignment: alignment,

      loadingBuilder: (context, child, progress) {

        if (progress == null) return child;

        return const Center(child: CircularProgressIndicator(strokeWidth: 2));

      },

      errorBuilder: (context, error, stackTrace) {

        if (_urlIndex + 1 < urls.length) {

          WidgetsBinding.instance.addPostFrameCallback((_) => _tryNextUrl());

          return const Center(child: CircularProgressIndicator(strokeWidth: 2));

        }

        return Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(Icons.broken_image_outlined, size: 48),

            const SizedBox(height: 8),

            Text('Could not load page ${widget.pageNumber}'),

          ],

        );

      },

    );

  }



  @override

  Widget build(BuildContext context) {

    final orientation = MediaQuery.orientationOf(context);

    final fillWidthLandscape = widget.landscapeScrollReading &&

        orientation == Orientation.landscape;



    if (!fillWidthLandscape) {

      return InteractiveViewer(

        minScale: 0.8,

        maxScale: 3,

        child: Center(

          child: _networkImage(

            fit: BoxFit.contain,

            width: null,

            height: null,

            alignment: Alignment.center,

          ),

        ),

      );

    }



    return LayoutBuilder(

      builder: (context, constraints) {

        final w = constraints.maxWidth;

        return ColoredBox(

          color: const Color(0xFFFDF8ED),

          child: SingleChildScrollView(

            physics: const BouncingScrollPhysics(),

            child: InteractiveViewer(

              minScale: 1,

              maxScale: 3,

              child: _networkImage(

                fit: BoxFit.fitWidth,

                width: w,

                height: null,

                alignment: Alignment.topCenter,

              ),

            ),

          ),

        );

      },

    );

  }

}


