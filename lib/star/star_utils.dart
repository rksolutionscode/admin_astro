final List<String> rasis = [
  "அனைத்து நட்சத்திரங்கள்", // ID = 0 (placeholder)
  "அஷ்வினி", // ID = 1
  "பரணி", // ID = 2
  "கார்த்திகை", // ID = 3
  "ரோகிணி", // ID = 4
  "மிருகசீரிடம்", // ID = 5
  "திருவாதிரை", // ID = 6
  "புனர்பூசம்", // ID = 7
  "பூசம்", // ID = 8
  "ஆயில்யம்", // ID = 9
  "மகம்", // ID = 10
  "பூரம்", // ID = 11
  "உத்திரம்", // ID = 12
  "ஹஸ்தம்", // ID = 13
  "சித்திரை", // ID = 14
  "சுவாதி", // ID = 15
  "விசாகம்", // ID = 16
  "அனுஷம்", // ID = 17
  "கேட்டை", // ID = 18
  "மூலம்", // ID = 19
  "பூராடம்", // ID = 20
  "உத்திராடம்", // ID = 21
  "திருவோணம்", // ID = 22
  "அவிட்டம்", // ID = 23
  "சதயம்", // ID = 24
  "பூரட்டாதி", // ID = 25
  "உத்திரட்டாதி", // ID = 26
  "ரேவதி", // ID = 27
];

/// Name → ID
int? starNameToId(String name) {
  final index = rasis.indexOf(name);
  if (index == -1) return null;
  return index; // index is the ID
}

/// ID → Name
String? starIdToName(int id) {
  if (id < 0 || id >= rasis.length) return null;
  return rasis[id];
}
