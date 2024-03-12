import 'package:flutter/material.dart';

import 'cleaner_color.dart';

ThemeData themeDark = ThemeData(
  fontFamily: 'Inter',
  dividerColor: _colors.primary3,
  extensions: const [_colors],
);

const _colors = CleanerColor(
  primary1: Color(0xFFDFF2EF),
  primary2: Color(0xFFB0E0D6),
  primary3: Color(0xFF7BCCBC),
  primary4: Color(0xFF43B8A2),
  primary5: Color(0xFF00A88F),
  primary6: Color(0xFF00987C),
  primary7: Color(0xFF008B70),
  primary8: Color(0xFF007B60),
  primary9: Color(0xFF006B52),
  primary10: Color(0xFF004F37),
  neutral1: Color(0xFF161616),
  neutral3: Color(0xFFFFFFFF),
  neutral2: Color(0xFFECF5F5),
  neutral4: Color(0xFFDBDBDB),
  neutral5: Color(0xFFDBDBDB),
  selectedColor: Color(0xFF00B906),
  gradient1: LinearGradient(
    colors: [Color(0xFF3258F3), Color(0xFF2DA6FF)],
    stops: [2.38 / 100, 102.38 / 100],
    begin: Alignment(1, 1),
    end: Alignment(-1, -1),
  ),
  gradient2: LinearGradient(
    colors: [Color(0xFFFF7728), Color(0xFFFF984C)],
    stops: [5.79 / 100, 88.98 / 100],
    begin: Alignment(1, 1),
    end: Alignment(-1, -1),
  ),
  gradient3: LinearGradient(
    colors: [Color(0xFF33A752), Color(0xFF8DCB9E)],
    stops: [5.79 / 100, 88.98 / 100],
    begin: Alignment(1, 1),
    end: Alignment(-1, -1),
  ),
  gradient4: LinearGradient(
    colors: [Color(0xFFF43B2E), Color(0xFFFF5A7B)],
    stops: [13.64 / 100, 89.9 / 100],
    begin: Alignment(1, 1),
    end: Alignment(-1, -1),
  ),
  gradient5: LinearGradient(
    colors: [Color(0xFFFFD600), Color(0x80FFE662)],
    stops: [2.38 / 100, 102.38 / 100],
    begin: Alignment(1, 1),
    end: Alignment(-1, -1),
  ),
  textDisable: Color(0xFF9B9B9B),
  btnDisable: Color(0xFFBEBEBE),
);
