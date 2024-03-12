import 'package:flutter/material.dart';

import 'cleaner_color.dart';

ThemeData themeLight = ThemeData(
  fontFamily: 'Inter',
  dividerColor: _colors.primary3,
  extensions: const [_colors],
);

const _colors = CleanerColor(
  primary1: Color(0xFFE4F2FF),
  primary2: Color(0xFFBFDEFF),
  primary3: Color(0xFF96CAFF),
  primary4: Color(0xFF6DB5FF),
  primary5: Color(0xFF53A4FF),
  primary6: Color(0xFF4295FF),
  primary7: Color(0xFF4286F4),
  primary8: Color(0xFF3F74E0),
  primary9: Color(0xFF3D62CD),
  primary10: Color(0xFF354D6E),
  neutral1: Color(0xFF161616),
  neutral2: Color(0xFFEEF5FF),
  neutral3: Color(0xFFFFFFFF),
  neutral4: Color(0xFFDBDBDB),
  neutral5: Color(0xFF707070),
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
