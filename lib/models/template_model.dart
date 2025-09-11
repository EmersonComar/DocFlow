
class Template {
  int? id;
  String titulo;
  String conteudo;
  List<String> tags;

  Template({this.id, required this.titulo, required this.conteudo, required this.tags});

  // Converte um Template em um Map. As chaves devem corresponder aos nomes das colunas no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'conteudo': conteudo,
      'tags': tags.join(','), // Converte a lista de tags em uma única string separada por vírgulas
    };
  }

  // Converte um Map em um Template.
  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      id: map['id'],
      titulo: map['titulo'],
      conteudo: map['conteudo'],
      tags: map['tags'].split(','), // Converte a string de volta para uma lista de tags
    );
  }
}
