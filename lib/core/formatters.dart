const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

const _monthsLong = [
  'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
  'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
];

const _weekdaysLong = [
  'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
];

//ANGKA SATUAN PUNYA 2 DIGIT
String _two(int n) => n.toString().padLeft(2, '0');

//MEMECAH TANDA TITIK PADA EMAIL, LALU MENGUBAH HURUF PERTAMA TIAP KATA MENJADI KAPITAL
//CONTOH = rizky.anugrah@myshimizu.id menjadi "Rizky Anugrah"
String userNameFromEmail(String email) {
  final local = email.split('@').first;
  return local
      .split(RegExp(r'[._-]'))
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1))
      .join(' ');
}

//MEMECAH NAMA BERDASARKAN SPASI "Rizky Anugrah" menjadi "RA"
String initials(String name) =>
    name.split(' ').where((p) => p.isNotEmpty).map((p) => p[0]).take(2).join();

//MENGECEK APAKAH TANGGAL RIWAYAT POMPA HARI INI & BUKAN
String formatActivityTime(DateTime value) {
  final d = value.toLocal();
  final now = DateTime.now();
  final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
  final day = isToday ? 'Today' : '${_months[d.month - 1]} ${d.day}';
  return '$day, ${_two(d.hour)}:${_two(d.minute)}';
}

//MENGUBAH TOTAL DETIK MENJADI FORMAT MM:SS
String formatCountdown(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${_two(m)}:${_two(s)}';
}

//PROPERTI WEEKDAY & MONTH DIKURANG 1 KARENA INDEX LIST MULAI DARI 0
String headerDate(DateTime d) =>
    '${_weekdaysLong[d.weekday - 1]}, ${_monthsLong[d.month - 1]}, ${d.day}';