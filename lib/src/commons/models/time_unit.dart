import 'dart:convert';

enum TimeUnitSymbol {
  milliseconds('ms'),
  second('s'),
  minute('m'),
  hour('h');

  const TimeUnitSymbol(this.symbol);

  final String symbol;

  @override
  String toString() => symbol.toString();
}

class TimeUnit {
  const TimeUnit(this.value, [this.symbol = TimeUnitSymbol.milliseconds]);

  const TimeUnit.fromMs(this.value) : symbol = TimeUnitSymbol.milliseconds;
  const TimeUnit.fromSecond(this.value) : symbol = TimeUnitSymbol.second;
  const TimeUnit.fromMinute(this.value) : symbol = TimeUnitSymbol.minute;
  const TimeUnit.fromHour(this.value) : symbol = TimeUnitSymbol.hour;

  final TimeUnitSymbol symbol;
  final num value;

  TimeUnitSymbol get closestOptimalUnit {
    const symbolValues = TimeUnitSymbol.values;
    var currentSymbol = symbol;
    var currentValue = value;

    if (currentValue > 1000 &&
        currentSymbol.index == 0 &&
        currentSymbol.index + 1 < symbolValues.length) {
      currentValue /= 1000;
      currentSymbol = symbolValues[1];
    }

    while (currentValue > 60 && currentSymbol.index + 1 < symbolValues.length) {
      currentValue /= 60;
      currentSymbol = symbolValues[currentSymbol.index + 1];
    }

    while (currentValue < 1 && currentSymbol.index - 1 > 0) {
      if (currentSymbol.index > 1) {
        currentValue *= 60;
      } else {
        currentValue *= 1000;
      }
      currentSymbol = symbolValues[currentSymbol.index - 1];
    }

    return currentSymbol;
  }

  TimeUnit toOptimal() => to(closestOptimalUnit);

  TimeUnit to(TimeUnitSymbol symbol) {
    if (this.symbol == symbol) return this;

    const symbolValues = TimeUnitSymbol.values;
    var currentSymbol = this.symbol;
    var currentValue = value;

    while (currentSymbol.index < symbol.index) {
      if (currentSymbol.index == 0) {
        currentValue /= 1000;
      } else {
        currentValue /= 60;
      }
      currentSymbol = symbolValues[currentSymbol.index + 1];
    }

    while (currentSymbol.index > symbol.index) {
      if (currentSymbol.index == 1) {
        currentValue *= 1000;
      } else {
        currentValue *= 60;
      }
      currentSymbol = symbolValues[currentSymbol.index - 1];
    }
    return TimeUnit(currentValue, currentSymbol);
  }

  @override
  String toString() => '${value.toStringWithFixedOneOrZero()}';

  String toStringOptimal() => to(closestOptimalUnit).toStringWithSymbol();

  String toStringWithSymbol() => '$this$symbol';

  TimeUnit operator -(TimeUnit other) {
    return TimeUnit(value - other.to(symbol).value, symbol);
  }

  TimeUnit operator +(TimeUnit other) {
    return TimeUnit(value + other.to(symbol).value, symbol);
  }

  TimeUnit operator *(int other) {
    return TimeUnit(value * other, symbol);
  }

  TimeUnit operator /(int other) {
    return TimeUnit(value * other, symbol);
  }

  bool operator >(TimeUnit other) {
    return value > other.to(symbol).value;
  }

  bool operator <(TimeUnit other) {
    return value < other.to(symbol).value;
  }

  bool operator <=(TimeUnit other) {
    final convertedOther = other.to(symbol);
    return this < convertedOther || this == convertedOther;
  }

  bool operator >=(TimeUnit other) {
    final convertedOther = other.to(symbol);
    return this > convertedOther || this == convertedOther;
  }

  @override
  bool operator ==(covariant TimeUnit other) {
    if (identical(this, other)) return true;
    final convertedOther = other.to(symbol);
    return convertedOther.value == value;
  }

  @override
  int get hashCode => symbol.hashCode ^ value.hashCode;

  TimeUnit copyWith({
    TimeUnitSymbol? symbol,
    num? value,
  }) {
    return TimeUnit(
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

  factory TimeUnit.fromMap(Map<String, dynamic> map) {
    return TimeUnit(
      map['value'] as num,
      TimeUnitSymbol.values[map['symbol']],
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeUnit.fromJson(String source) =>
      TimeUnit.fromMap(json.decode(source) as Map<String, dynamic>);
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

extension TimeExtension on num {
  TimeUnit get millisecond => TimeUnit(toInt());

  TimeUnit get second => TimeUnit.fromSecond(this);

  TimeUnit get minute => TimeUnit.fromMinute(this);

  TimeUnit get hour => TimeUnit.fromHour(this);
}
