class ParaData {
  final int number;
  final String arabicName;
  final String englishName;
  final List<int> surahNumbers;

  const ParaData(
    this.number,
    this.arabicName,
    this.englishName,
    this.surahNumbers,
  );
}

const List<ParaData> quranParas = [
  ParaData(1, 'الم', 'Alif Lam Meem', [1, 2]),
  ParaData(2, 'سَيَقُولُ', 'Sayaqool', [2]),
  ParaData(3, 'تِلْكَ الرُّسُلُ', 'Tilkar Rusul', [2, 3]),
  ParaData(4, 'لَنْ تَنَالُوا', 'Lan Tana Loo', [3, 4]),
  ParaData(5, 'وَالْمُحْصَنَاتُ', 'Wal Mohsanat', [4, 5]),
  ParaData(6, 'لَا يُحِبُّ اللّٰهُ', 'La Yuhibbullah', [4, 5, 6]),
  ParaData(7, 'وَإِذَا سَمِعُوا', 'Wa Iza Samiu', [5, 6, 7]),
  ParaData(8, 'وَلَوْ أَنَّنَا', 'Wa Lau Annana', [6, 7, 8]),
  ParaData(9, 'قَالَ الْمَلَأُ', 'Qalal Malao', [7, 8, 9]),
  ParaData(10, 'وَاعْلَمُوا', 'Wa Alamu', [8, 9, 10]),
  ParaData(11, 'يَعْتَذِرُونَ', 'Yatazeroon', [9, 10, 11]),
  ParaData(12, 'وَمَا مِنْ دَابَّةٍ', 'Wa Ma Min Dabbah', [11, 12]),
  ParaData(13, 'وَمَا أُبَرِّئُ', 'Wa Ma Ubarrio', [12, 13, 14]),
  ParaData(14, 'رُبَمَا', 'Rubama', [15, 16]),
  ParaData(15, 'سُبْحَانَ الَّذِي', 'Subhanalladhi', [17, 18]),
  ParaData(16, 'قَالَ أَلَمْ', 'Qal Alam', [18, 19, 20]),
  ParaData(17, 'اقْتَرَبَ', 'Iqtaraba', [21, 22]),
  ParaData(18, 'قَدْ أَفْلَحَ', 'Qaad Aflaha', [23, 24, 25]),
  ParaData(19, 'وَقَالَ الَّذِينَ', 'Wa Qalallazina', [25, 26, 27]),
  ParaData(20, 'أَمَّنْ خَلَقَ', 'Amman Khalaqa', [27, 28, 29]),
  ParaData(21, 'اتْلُ مَا أُوحِيَ', 'Utlu Ma Oohiya', [29, 30, 31, 32, 33]),
  ParaData(22, 'وَمَنْ يَقْنُتْ', 'Wa Manyaqnut', [33, 34, 35, 36]),
  ParaData(23, 'وَمَا لِيَ', 'Wa Mali', [36, 37, 38, 39]),
  ParaData(24, 'فَمَنْ أَظْلَمُ', 'Fa Man Azlamu', [39, 40, 41]),
  ParaData(25, 'إِلَيْهِ يُرَدُّ', 'Elahe Yuraddo', [41, 42, 43, 44, 45]),
  ParaData(26, 'حم', 'Ha Meem', [46, 47, 48, 49, 50, 51]),
  ParaData(27, 'قَالَ فَمَا خَطْبُكُمْ', 'Qala Fama Khatbukum', [51, 52, 53, 54, 55, 56, 57]),
  ParaData(28, 'قَدْ سَمِعَ اللّٰهُ', 'Qad Sami Allah', [58, 59, 60, 61, 62, 63, 64, 65, 66]),
  ParaData(29, 'تَبَارَكَ الَّذِي', 'Tabarakallazi', [67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77]),
  ParaData(30, 'عَمَّ', 'Amma', [
    78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
    96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110,
    111, 112, 113, 114,
  ]),
];
