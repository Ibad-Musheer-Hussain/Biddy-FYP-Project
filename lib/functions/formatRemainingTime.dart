// ignore_for_file: file_names
String formatRemainingTime(Duration remainingTime) {
  if (remainingTime.isNegative) {
    return '00:00:00:00'; // Or handle negative time as needed
  }

  int totalSeconds = remainingTime.inSeconds;
  int days = totalSeconds ~/ (3600 * 24);
  int hours = (totalSeconds % (3600 * 24)) ~/ 3600;
  int minutes = (totalSeconds % 3600) ~/ 60;
  int seconds = totalSeconds % 60;

  return '${days.toString().padLeft(2, '0')}:'
      '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

Duration calculateRemainingTime(int timestamp) {
  DateTime endTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return endTime.difference(DateTime.now());
}
