class Template {
  final int? id;
  final String titulo;
  final String conteudo;
  final List<String> tags;

  const Template({
    this.id,
    required this.titulo,
    required this.conteudo,
    required this.tags,
  });

  Template copyWith({
    int? id,
    String? titulo,
    String? conteudo,
    List<String>? tags,
  }) {
    return Template(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Template &&
        other.id == id &&
        other.titulo == titulo &&
        other.conteudo == conteudo;
  }

  @override
  int get hashCode => Object.hash(id, titulo, conteudo);
}