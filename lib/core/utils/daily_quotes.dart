import 'dart:math';

class Quotes {
  Quotes._();

  static const _list = [
    'Discipline\nbeats\nmotivation.',
    'Consistency\ncreates\nsuccess.',
    'Small actions\ncompound.',
    'Win the\nmorning.',
    'No shortcuts.\nNo excuses.',
    'Earn your\nrest.',
    'Your future self\nis watching.',
    'Comfort is\nthe enemy.',
    'Be harder\nto stop.',
    'Do the work\nno one sees.',
    'Outwork\nyesterday.',
    'Make today\ncount.',
    'Train your\nmind first.',
    'Stay the\ncourse.',
    'Focus over\nfeelings.',
    'No zero\ndays.',
    'Own the\nday.',
    'Execute\nmercilessly.',
    'Raise your\nstandards.',
    'Show up\nsharp.',
    'The streak\nmatters.',
    'Hard days\nbuild you.',
    'One decision\nat a time.',
    'Be the\nexception.',
    'Control what\nyou can.',
    'Never\nskip twice.',
    'Prove it\nto yourself.',
    'Silence\nthe noise.',
    'Move with\npurpose.',
    'Built, not\nborn.',
  ];

  static const _images = [
    'assets/images/bg1.jpg',
    'assets/images/bg2.jpg',
    'assets/images/bg3.jpg',
    'assets/images/bg4.jpg',
    'assets/images/bg5.jpg',
    'assets/images/bg6.jpg',
    'assets/images/bg7.jpg',
    'assets/images/bg8.jpg',
  ];

  static String random() => _list[Random().nextInt(_list.length)];

  static String randomBg() {
    final r = Random().nextInt(_images.length);
    return _images[r];
  }
}