import '../utils/location_categories.dart';

class SearchResponse {
  Geocoding? geocoding;
  String type;
  List<Feature> features;
  List<double> bbox;

  SearchResponse(
    this.geocoding,
    this.type,
    this.features,
    this.bbox,
  );

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
        Geocoding.fromJson(json["geocoding"]),
        json["type"],
        List<Feature>.from(json["features"].map((x) => Feature.fromJson(x))),
        json["bbox"] == null
            ? []
            : List<double>.from(json["bbox"].map((x) => x?.toDouble())),
      );
}

class Feature {
  String type;
  Geometry geometry;
  Properties properties;

  Feature({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  bool isStreet() {
    return (properties.category[0] == LocationCategory.street.name ||
        properties.category[0] == LocationCategory.vegadresse.name);
  }

  bool isPoi() {
    return (properties.category[0] == LocationCategory.poi.name ||
        properties.category[0] == LocationCategory.GroupOfStopPlaces.name);
  }

  bool isStopPlace() {
    return properties.id.contains("NSR") &&
        properties.category[0] != LocationCategory.GroupOfStopPlaces.name;
  }

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json["type"],
        geometry: Geometry.fromJson(json["geometry"]),
        properties: Properties.fromJson(json["properties"]),
      );
}

class Geometry {
  String? type;
  List<double> coordinates;

  Geometry(
    this.type,
    this.coordinates,
  );

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        json["type"],
        List<double>.from(json["coordinates"].map((x) => x?.toDouble())),
      );
}

class Properties {
  String id;
  String gid;
  String layer;
  String source;
  String sourceId;
  String name;
  String? street;
  String? accuracy;
  String? countryA;
  String? county;
  String? countyGid;
  String? locality;
  String? localityGid;
  String? label;
  List<String> category;
  List<String>? tariffZones;

  Properties(
    this.id,
    this.gid,
    this.layer,
    this.source,
    this.sourceId,
    this.name,
    this.street,
    this.accuracy,
    this.countryA,
    this.county,
    this.countyGid,
    this.locality,
    this.localityGid,
    this.label,
    this.category,
    this.tariffZones,
  );

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        json["id"],
        json["gid"],
        json["layer"],
        json["source"],
        json["source_id"],
        json["name"],
        json["street"],
        json["accuracy"],
        json["country_a"],
        json["county"],
        json["county_gid"],
        json["locality"],
        json["locality_gid"],
        json["label"],
        List<String>.from(json["category"].map((x) => x)),
        json["tariff_zones"] == null
            ? []
            : List<String>.from(json["tariff_zones"].map((x) => x)),
      );
}

class Geocoding {
  String? version;
  String? attribution;
  Query? query;
  Engine? engine;
  int? timestamp;

  Geocoding({
    this.version,
    this.attribution,
    this.query,
    this.engine,
    this.timestamp,
  });

  factory Geocoding.fromJson(Map<String, dynamic> json) => Geocoding(
        version: json["version"],
        attribution: json["attribution"],
        query: json["query"] == null ? null : Query.fromJson(json["query"]),
        engine: json["engine"] == null ? null : Engine.fromJson(json["engine"]),
        timestamp: json["timestamp"],
      );
}

class Engine {
  String? name;
  String? author;
  String? version;

  Engine({
    this.name,
    this.author,
    this.version,
  });

  factory Engine.fromJson(Map<String, dynamic> json) => Engine(
        name: json["name"],
        author: json["author"],
        version: json["version"],
      );
}

class Query {
  String? text;
  String? parser;
  List<String>? tokens;
  int? size;
  List<String>? layers;
  List<String>? sources;
  bool? private;
  Lang? lang;
  int? querySize;

  Query({
    this.text,
    this.parser,
    this.tokens,
    this.size,
    this.layers,
    this.sources,
    this.private,
    this.lang,
    this.querySize,
  });

  factory Query.fromJson(Map<String, dynamic> json) => Query(
        text: json["text"],
        parser: json["parser"],
        tokens: json["tokens"] == null
            ? []
            : List<String>.from(json["tokens"].map((x) => x)),
        size: json["size"],
        layers: json["layers"] == null
            ? []
            : List<String>.from(json["layers"].map((x) => x)),
        sources: json["sources"] == null
            ? []
            : List<String>.from(json["sources"].map((x) => x)),
        private: json["private"],
        lang: json["lang"] == null ? null : Lang.fromJson(json["lang"]),
        querySize: json["querySize"],
      );
}

class Lang {
  String? name;
  String? iso6391;
  String? iso6393;
  bool? defaulted;

  Lang({
    this.name,
    this.iso6391,
    this.iso6393,
    this.defaulted,
  });

  factory Lang.fromJson(Map<String, dynamic> json) => Lang(
        name: json["name"],
        iso6391: json["iso6391"],
        iso6393: json["iso6393"],
        defaulted: json["defaulted"],
      );
}

enum PropertyType { street, stopPlace }
