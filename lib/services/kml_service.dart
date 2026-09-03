import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';
import '../models/farm_model.dart';

class KmlService {
  /// Direct fetch from Google My Maps without any proxy layer
  static Future<
    List<
      FarmModel
    >
  >
  fetchMyMapsFarms(
    String mapId,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final directUrl = 'https://www.google.com/maps/d/kml?mid=$mapId&forcekml=1&_t=$timestamp';

    return _fetchAndParseUrl(
      directUrl,
      mapId,
    );
  }

  static Future<
    List<
      FarmModel
    >
  >
  _fetchAndParseUrl(
    String targetUrl,
    String mapId,
  ) async {
    final response = await http.get(
      Uri.parse(
        targetUrl,
      ),
    );

    if (response.statusCode !=
        200) {
      throw Exception(
        'Failed to load map data (HTTP ${response.statusCode}).',
      );
    }

    String kmlContent;

    // Unzip KMZ if binary payload is returned
    if (response.bodyBytes.length >
            4 &&
        response.bodyBytes[0] ==
            0x50 &&
        response.bodyBytes[1] ==
            0x4B) {
      final archive = ZipDecoder().decodeBytes(
        response.bodyBytes,
      );
      final kmlFile = archive.files.firstWhere(
        (
          file,
        ) => file.name.endsWith(
          '.kml',
        ),
        orElse: () => throw Exception(
          'No .kml payload found inside archive.',
        ),
      );
      kmlContent = utf8.decode(
        kmlFile.content
            as List<
              int
            >,
      );
    } else {
      kmlContent = response.body;
    }

    final trimmed = kmlContent.trim().toLowerCase();
    if (trimmed.startsWith(
          '<!doctype html',
        ) ||
        trimmed.startsWith(
          '<html',
        )) {
      throw Exception(
        'Google returned an HTML web page instead of KML data. Ensure map sharing is "Anyone with the link".',
      );
    }

    final document = XmlDocument.parse(
      kmlContent,
    );

    // Follow Google NetworkLink redirect if returned
    final hrefNodes = document.findAllElements(
      'href',
    );
    for (final hrefNode in hrefNodes) {
      final hrefText = hrefNode.innerText.trim();
      if (hrefText.contains(
        'google.com/maps/d/kml',
      )) {
        return _fetchAndParseUrl(
          hrefText,
          mapId,
        );
      }
    }

    return _parseKmlToFarms(
      document,
      mapId,
    );
  }

  static List<
    FarmModel
  >
  _parseKmlToFarms(
    XmlDocument document,
    String mapId,
  ) {
    final List<
      FarmModel
    >
    farms = [];
    final placemarkNodes = document.findAllElements(
      'Placemark',
    );

    int index = 1;
    for (final placemark in placemarkNodes) {
      final nameElement = placemark
          .findElements(
            'name',
          )
          .firstOrNull;
      final farmName =
          (nameElement?.innerText.trim().isNotEmpty ==
              true)
          ? nameElement!.innerText.trim()
          : 'Field #$index';

      final List<
        LatLng
      >
      points = [];
      final coordinatesNodes = placemark.findAllElements(
        'coordinates',
      );

      for (final node in coordinatesNodes) {
        final rawString = node.innerText.trim();
        final pointTuples = rawString.split(
          RegExp(
            r'\s+',
          ),
        );

        for (final tuple in pointTuples) {
          if (tuple.trim().isEmpty) continue;

          final parts = tuple.split(
            ',',
          );
          if (parts.length >=
              2) {
            final lng = double.tryParse(
              parts[0],
            );
            final lat = double.tryParse(
              parts[1],
            );

            if (lat !=
                    null &&
                lng !=
                    null) {
              points.add(
                LatLng(
                  lat,
                  lng,
                ),
              );
            }
          }
        }
      }

      if (points.length >=
          3) {
        farms.add(
          FarmModel.fromKmlPlacemark(
            id: '$mapId-$index',
            name: farmName,
            mapId: mapId,
            points: points,
          ),
        );
        index++;
      }
    }

    if (farms.isEmpty) {
      throw Exception(
        'No valid polygon shapes found in the My Maps link.',
      );
    }

    return farms;
  }
}
