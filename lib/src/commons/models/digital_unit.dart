import 'dart:convert';

import 'package:meta/meta.dart';

enum DigitalUnitSymbol {
  byte('B'),
  kilobyte('kB'),
  megabyte('MB'),
  gigabyte('GB');

  const DigitalUnitSymbol(this.symbol);

  final String symbol;

  @override
  String toString() => symbol.toString();
}

@sealed
@immutable
class DigitalUnit implements Comparable {
  const DigitalUnit(this.value, [this.symbol = DigitalUnitSymbol.byte]);

  const DigitalUnit.fromByte(this.value) : symbol = DigitalUnitSymbol.byte;
  const DigitalUnit.fromKB(this.value) : symbol = DigitalUnitSymbol.kilobyte;
  const DigitalUnit.fromMB(this.value) : symbol = DigitalUnitSymbol.megabyte;
  const DigitalUnit.fromGB(this.value) : symbol = DigitalUnitSymbol.gigabyte;

  final DigitalUnitSymbol symbol;
  final num value;

  DigitalUnitSymbol get closestOptimalUnit {
    const symbolValues = DigitalUnitSymbol.values;
    var currentSymbol = symbol;
    var currentValue = value;

    while (
        currentValue > 1000 && currentSymbol.index + 1 < symbolValues.length) {
      currentValue /= 1024;
      currentSymbol = symbolValues[currentSymbol.index + 1];
    }

    while (currentValue < 0 && currentSymbol.index - 1 > 0) {
      currentValue *= 1024;
      currentSymbol = symbolValues[currentSymbol.index - 1];
    }

    return currentSymbol;
  }

  DigitalUnit toOptimal() => to(closestOptimalUnit);

  DigitalUnit to(DigitalUnitSymbol symbol) {
    if (this.symbol == symbol) return this;

    const symbolValues = DigitalUnitSymbol.values;
    var currentSymbol = this.symbol;
    var currentValue = value;

    while (currentSymbol.index < symbol.index) {
      currentValue /= 1024;
      currentSymbol = symbolValues[currentSymbol.index + 1];
    }

    while (currentSymbol.index > symbol.index) {
      currentValue *= 1024.0;
      currentSymbol = symbolValues[currentSymbol.index - 1];
    }

    return DigitalUnit(currentValue, currentSymbol);
  }

  @override
  String toString() => '${value.toStringWithFixedOneOrZero()}';

  String toStringOptimal() => to(closestOptimalUnit).toStringWithSymbol();

  String toStringWithSymbol() => '$this $symbol';

  DigitalUnit operator -(DigitalUnit other) {
    return DigitalUnit(value - other.to(symbol).value, symbol);
  }

  DigitalUnit operator +(DigitalUnit other) {
    return DigitalUnit(value + other.to(symbol).value, symbol);
  }

  DigitalUnit operator *(num other) {
    return DigitalUnit(value * other, symbol);
  }

  DigitalUnit operator /(num other) {
    return DigitalUnit(value * other, symbol);
  }

  bool operator >(DigitalUnit other) {
    return value > other.to(symbol).value;
  }

  bool operator <(DigitalUnit other) {
    return value < other.to(symbol).value;
  }

  bool operator <=(DigitalUnit other) {
    final convertedOther = other.to(symbol);
    return this < convertedOther || this == convertedOther;
  }

  bool operator >=(DigitalUnit other) {
    final convertedOther = other.to(symbol);
    return this > convertedOther || this == convertedOther;
  }

  @override
  bool operator ==(covariant DigitalUnit other) {
    if (identical(this, other)) return true;
    final convertedOther = other.to(symbol);
    return convertedOther.value == value;
  }

  @override
  int compareTo(covariant DigitalUnit other) {
    if (identical(this, other)) return 0;
    final convertedOther = other.to(symbol);
    return value.compareTo(convertedOther.value);
  }

  @override
  int get hashCode => symbol.hashCode ^ value.hashCode;

  DigitalUnit copyWith({
    DigitalUnitSymbol? symbol,
    num? value,
  }) {
    return DigitalUnit(
      value ?? this.value,
      symbol ?? this.symbol,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'value': value,
      'symbol': symbol.index,
    };
  }

  factory DigitalUnit.fromMap(Map<String, dynamic> map) {
    return DigitalUnit(
      map['value'] as num,
      DigitalUnitSymbol.values[map['symbol']],
    );
  }

  String toJson() => json.encode(toMap());

  factory DigitalUnit.fromJson(String source) =>
      DigitalUnit.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension on num {
  toStringWithFixedOneOrZero() {
    final toString = toStringAsFixed(1);
    if (toString.endsWith('.0')) {
      return toString.substring(0, toString.length - 2);
    }

    return toString;
  }
}

extension NumberExtension on num {
  DigitalUnit get bytes => DigitalUnit(toInt());

  DigitalUnit get kb => DigitalUnit.fromKB(this);

  DigitalUnit get mb => DigitalUnit.fromMB(this);

  DigitalUnit get gb => DigitalUnit.fromGB(this);
}
