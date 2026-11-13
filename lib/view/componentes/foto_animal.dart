import 'package:flutter/material.dart';

import '../../core/app_tema.dart';
import '../../model/animal_model.dart';

/// Foto do animal: link informado pela ONG (fotoUrl), imagem em assets
/// ou, na falta das duas (ou se não carregar), um ícone de patinha.
class FotoAnimal extends StatelessWidget {
  const FotoAnimal({super.key, required this.animal, this.tamanhoIcone = 48});

  final Animal animal;
  final double tamanhoIcone;

  @override
  Widget build(BuildContext context) {
    final gato = animal.especie == Especie.gato;

    final icone = ColoredBox(
      color: gato ? const Color(0xFFD9F2EF) : const Color(0xFFFBE3DC),
      child: Center(
        child: Icon(
          Icons.pets,
          size: tamanhoIcone,
          color: gato ? AppCores.verde : AppCores.coral,
        ),
      ),
    );

    final url = animal.fotoUrl;
    final asset = animal.imagem;

    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        semanticLabel: 'Foto de ${animal.nome}',
        errorBuilder: (context, error, stackTrace) => icone,
      );
    }

    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        semanticLabel: 'Foto de ${animal.nome}',
        errorBuilder: (context, error, stackTrace) => icone,
      );
    }

    return icone;
  }
}