import 'dart:math';

class DailyQuotes {
  DailyQuotes._();

  static const _quotes = [
    'Discipline\nBeats\nMotivation.',
    'Consistency\nCreates\nSuccess.',
    'Small actions\ncompound.',
    'Win the\nmorning.',
    'No shortcuts.\nNo excuses.',
    'Earn your\nrest.',
    'Your future self\nis watching.',
    'Comfort is\nthe enemy.',
    'One day\nor day one.',
    'Be harder\nto stop.',
    'Do the work\nno one sees.',
    'Outwork\nyesterday.',
    'Make today\ncount.',
    'Train your\nmind first.',
    'Stay the\ncourse.',
    'Prove it\nto yourself.',
    'Hard days\nbuild you.',
    'Focus over\nfeelings.',
    'No zero\ndays.',
    'Own the\nday.',
    'Execute\nmercilessly.',
    'Silence the\nnoise.',
    'Raise your\nstandards.',
    'Show up\nsharp.',
    'The streak\nmatters.',
  ];

  static String random() {
    final rng = Random();
    return _quotes[rng.nextInt(_quotes.length)];
  }

  static const List<String> bgImages = [
    'assets/images/bg1.jpg',
    'assets/images/bg2.jpg',
    'assets/images/bg3.jpg',
    'assets/images/bg4.jpg',
    'assets/images/bg5.jpg',
  ];

  static String randomBg() {
    final rng = Random();
    return bgImages[rng.nextInt(bgImages.length)];
  }
}