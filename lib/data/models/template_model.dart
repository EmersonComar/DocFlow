import '../../domain/entities/template.dart';

class TemplateModel extends Template {
  const TemplateModel({
    super.id,
    required super.titulo,
    required super.conteudo,
    required super.tags,
  });

  factory TemplateModel.fromEntity(Template template) {
    return TemplateModel(
      id: template.id,
      titulo: template.titulo,
      conteudo: template.conteudo,
      tags: template.tags,
    );
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    final tagsString = map['tags'] as String?;
    final tags = tagsString != null && tagsString.isNotEmpty
        ? tagsString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return TemplateModel(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      conteudo: map['conteudo'] as String,
      tags: tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'conteudo': conteudo,
    };
  }

  Template toEntity() {
    return Template(
      id: id,
      titulo: titulo,
      conteudo: conteudo,
      tags: tags,
    );
  }
}