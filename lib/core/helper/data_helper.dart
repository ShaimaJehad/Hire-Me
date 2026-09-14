String formatTime(DateTime time) {
  final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final m = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $period';
}

String formatDate(DateTime time) {
  final now = DateTime.now();
  if (time.day == now.day) return 'Today ${formatTime(time)}';
  return '${time.day}/${time.month}/${time.year}';
}
