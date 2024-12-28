class Note {
  final String date;
  final String text;

  Note({required this.date, required this.text});

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'text': text
    };
  }

  // Reconvert from JSON to List
  factory Note.fromJson(Map<String, dynamic> json){
    return Note(
      date: json['date'],
      text: json['text']
      );
  }
}