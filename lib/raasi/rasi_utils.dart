int? rasiNameToId(String rasiName) {
  const map = {
    'மேஷம்': 1,
    'ரிஷபம்': 2,
    'மிதுனம்': 3,
    'கடகம்': 4,
    'சிம்மம்': 5,
    'கன்னி': 6,
    'துலாம்': 7,
    'விருச்சிகம்': 8,
    'தனுசு': 9,
    'மகரம்': 10,
    'கும்பம்': 11,
    'மீனம்': 12,
  };
  return map[rasiName];
}

String? rasiIdToName(int id) {
  const map = {
    1: 'மேஷம்',
    2: 'ரிஷபம்',
    3: 'மிதுனம்',
    4: 'கடகம்',
    5: 'சிம்மம்',
    6: 'கன்னி',
    7: 'துலாம்',
    8: 'விருச்சிகம்',
    9: 'தனுசு',
    10: 'மகரம்',
    11: 'கும்பம்',
    12: 'மீனம்',
  };
  return map[id];
}

String formatNotesByWords(String text, int wordsPerLine) {
  final words = text.split(RegExp(r'\s+'));
  final buffer = StringBuffer();
  for (int i = 0; i < words.length; i++) {
    buffer.write(words[i]);
    if ((i + 1) % wordsPerLine == 0) {
      buffer.write('\n');
    } else {
      buffer.write(' ');
    }
  }
  return buffer.toString().trim();
}
