import 'package:phone_cleaner/src/commons/models/digital_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test All Calculations', () {
    expect(12.bytes - 5.bytes, equals(7.bytes));
    expect(5.bytes - 5.bytes, equals(0.bytes));
    expect(5.bytes - 12.bytes, equals((-7).bytes));
    expect(12.bytes - 5.bytes, greaterThan(5.bytes));

    expect(12.bytes + 5.bytes, equals(17.bytes));
    expect(5.bytes + 5.bytes, equals(10.bytes));
    expect(12.bytes + 5.bytes, greaterThan(15.bytes));

    expect(5.bytes * 2, equals(10.bytes));
    expect(5.bytes * -2, equals((-10).bytes));
    expect(0.bytes * 2, equals(0.bytes));
  });

  test('Test Conversions', () {
    expect(1.kb, equals(1024.bytes));
    expect(1.mb, equals(1048576.bytes));
    expect(1.gb, equals(1073741824.bytes));

    expect(1024.bytes, equals(1.kb));
    expect(1048576.bytes, equals(1.mb));
    expect(1073741824.bytes, equals(1.gb));

    expect(1.kb.to(DigitalUnitSymbol.byte), equals(1.kb));
    expect(1.mb.to(DigitalUnitSymbol.byte), equals(1.mb));
    expect(1.gb.to(DigitalUnitSymbol.byte), equals(1.gb));
    expect(256.gb.to(DigitalUnitSymbol.gigabyte).value.toInt(), equals(256));
  });

  test('Test ToString', () {
    expect(1.bytes.toString(), equals('1'));
    expect(1.kb.toString(), equals('1'));
    expect(1.mb.toString(), equals('1'));
    expect(1.gb.toString(), equals('1'));

    expect(
        1.kb.to(DigitalUnitSymbol.byte).toStringWithSymbol(), equals('1024 B'));
    expect(1.mb.to(DigitalUnitSymbol.byte).toStringWithSymbol(),
        equals('1048576 B'));
    expect(1.gb.to(DigitalUnitSymbol.byte).toStringWithSymbol(),
        equals('1073741824 B'));

    expect(1.kb.to(DigitalUnitSymbol.byte).toStringOptimal(), equals('1 kB'));
    expect(1.mb.to(DigitalUnitSymbol.byte).toStringOptimal(), equals('1 MB'));
    expect(1.gb.to(DigitalUnitSymbol.byte).toStringOptimal(), equals('1 GB'));

    expect(
        2.4.kb.to(DigitalUnitSymbol.byte).toStringOptimal(), equals('2.4 kB'));
    expect(
        2.8.mb.to(DigitalUnitSymbol.byte).toStringOptimal(), equals('2.8 MB'));
    expect(
        2.87.gb.to(DigitalUnitSymbol.byte).toStringOptimal(), equals('2.9 GB'));
  });
}
