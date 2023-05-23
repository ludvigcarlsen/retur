import '../utils/transportmodes.dart';

class Filter {
  final ExcludeModes not;
  double walkSpeed;

  Filter.def()
      : not = ExcludeModes.def(),
        walkSpeed = 4.2;

  Filter(this.not, this.walkSpeed);

  Map<String, dynamic> toJson() =>
      {'not': not.toJson(), 'walkSpeed': walkSpeed};

  Map<String, dynamic> toQueryJson() => {'not': not.toQueryJson()};

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(ExcludeModes.fromJson(json['not']), json['walkSpeed']);
  }

  factory Filter.from(Filter filter) {
    return Filter(ExcludeModes.from(filter.not), filter.walkSpeed);
  }
}

class ExcludeModes {
  final Set<TransportMode> transportModes;

  ExcludeModes.def() : transportModes = {};
  ExcludeModes(this.transportModes);

  Map<String, dynamic> toJson() {
    return {'transportModes': transportModes.map((mode) => mode.name).toList()};
  }

  Map<String, dynamic> toQueryJson() {
    if (transportModes.isNotEmpty) {
      return {
        'transportModes': transportModes.map((mode) => mode.toJson()).toList()
      };
    }
    return {'transportModes': {}};
  }

  factory ExcludeModes.fromJson(Map<String, dynamic> json) {
    return ExcludeModes(json['transportModes']
        .map<TransportMode>((e) => TransportMode.fromJson(e['transportMode']))
        .toSet());
  }

  factory ExcludeModes.from(ExcludeModes excludeModes) {
    return ExcludeModes(Set.from(excludeModes.transportModes));
  }
}
