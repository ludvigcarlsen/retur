import 'package:flutter/foundation.dart';

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

  Map<String, dynamic> toQueryJson() => {'not': not.toJson()};

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(ExcludeModes.fromJson(json['not']), json['walkSpeed']);
  }
}

class ExcludeModes {
  final Set<TransportMode> modes;

  ExcludeModes.def() : modes = {};
  ExcludeModes(this.modes);

  Map<String, dynamic> toJson() {
    if (modes.isNotEmpty) {
      return {'transportModes': modes.map((mode) => mode.toJson()).toList()};
    }
    return {'transportModes': {}};
  }

  factory ExcludeModes.fromJson(Map<String, dynamic> json) {
    return ExcludeModes(json['transportModes']
        .map<TransportMode>((e) => TransportMode.fromJson(e['transportMode']))
        .toSet());
  }
}
