class SearchResponse {
  Geocoding? geocoding;
  String? type;
  List<Feature> features;
  List<double> bbox;

  SearchResponse({
    this.geocoding,
    this.type,
    required this.features,
    required this.bbox,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
        geocoding: json["geocoding"] == null
            ? null
            : Geocoding.fromJson(json["geocoding"]),
        type: json["type"],
        features: json["features"] == null
            ? []
            : List<Feature>.from(
                json["features"]!.map((x) => Feature.fromJson(x))),
        bbox: json["bbox"] == null
            ? []
            : List<double>.from(json["bbox"]!.map((x) => x?.toDouble())),
      );
}

class Feature {
  String? type;
  Geometry geometry;
  Properties properties;

  Feature({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json["type"],
        geometry: Geometry.fromJson(json["geometry"]),
        properties: Properties.fromJson(json["properties"]),
      );
}

class Geometry {
  String? type;
  List<double>? coordinates;

  Geometry({
    this.type,
    this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json["type"],
        coordinates: json["coordinates"] == null
            ? []
            : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
      );
}

class Properties {
  String id;
  String? gid;
  String? layer;
  String? source;
  String? sourceId;
  String name;
  String? street;
  String? accuracy;
  String? countryA;
  String? county;
  String? countyGid;
  String? locality;
  String? localityGid;
  String? label;
  List<String>? category;
  List<String>? tariffZones;

  Properties({
    required this.id,
    this.gid,
    this.layer,
    this.source,
    this.sourceId,
    required this.name,
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
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        id: json["id"],
        gid: json["gid"],
        layer: json["layer"],
        source: json["source"],
        sourceId: json["source_id"],
        name: json["name"],
        street: json["street"],
        accuracy: json["accuracy"],
        countryA: json["country_a"],
        county: json["county"],
        countyGid: json["county_gid"],
        locality: json["locality"],
        localityGid: json["locality_gid"],
        label: json["label"],
        category: json["category"] == null
            ? []
            : List<String>.from(json["category"]!.map((x) => x)),
        tariffZones: json["tariff_zones"] == null
            ? []
            : List<String>.from(json["tariff_zones"]!.map((x) => x)),
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
            : List<String>.from(json["tokens"]!.map((x) => x)),
        size: json["size"],
        layers: json["layers"] == null
            ? []
            : List<String>.from(json["layers"]!.map((x) => x)),
        sources: json["sources"] == null
            ? []
            : List<String>.from(json["sources"]!.map((x) => x)),
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
