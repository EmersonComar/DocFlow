
class Template {
  int? id;
  String titulo;
  String conteudo;
  List<String> tags;

  Template({this.id, required this.titulo, required this.conteudo, required this.tags});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'conteudo': conteudo,
    };
  }

  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      id: map['id'],
      titulo: map['titulo'],
      conteudo: map['conteudo'],
      tags: map.containsKey('tags') && map['tags'] != null ? map['tags'].split(',') : [],
    );
  }
}
