// Règles du mot de passe, et génération d'un mot de passe conforme.
//
// Séparé de `V` (widgets/fields.dart) parce que ce n'est pas de la logique
// d'interface : la règle et le générateur doivent rester d'accord, et un test
// vérifie que tout mot de passe produit ici passe la validation.

import 'dart:math';

class PasswordPolicy {
  PasswordPolicy._();

  static const minLength = 8;

  /// Longueur des mots de passe générés. Plus long que le minimum exigé :
  /// l'utilisateur n'a pas à le retenir ni à le saisir.
  static const generatedLength = 16;

  // Caractères ambigus écartés — le mot de passe généré est affiché en clair et
  // sera parfois recopié à la main : ni O/0, ni l/1/I.
  static const _minuscules = 'abcdefghijkmnopqrstuvwxyz';
  static const _majuscules = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _chiffres = '23456789';

  /// Symboles présents sur le premier écran des claviers mobiles, sans
  /// guillemets ni antislash qui se prêtent aux erreurs de saisie.
  static const symboles = r'!@#$%&*?+=-';

  static const _alphabet = '$_minuscules$_majuscules$_chiffres$symboles';

  /// Renvoie un message en français, ou null si le mot de passe convient.
  /// L'ordre des contrôles va du plus visible au plus fin, pour ne signaler
  /// qu'un seul problème à la fois.
  static String? validate(String value) {
    if (value.isEmpty) return 'Saisissez un mot de passe';
    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères';
    }
    // \p{Lu} et non [A-Z] : dans une application française « Été2026 » a bien
    // une majuscule, et la refuser serait incompréhensible.
    if (!value.contains(RegExp(r'\p{Lu}', unicode: true))) {
      return 'Ajoutez au moins une majuscule';
    }
    if (!_contientSymbole(value)) {
      return 'Ajoutez au moins un symbole (par exemple ! ? @ #)';
    }
    return null;
  }

  /// Un symbole est tout ce qui n'est ni lettre, ni chiffre, ni espace — plus
  /// large que [symboles], pour ne pas refuser un mot de passe légitime tapé
  /// avec un caractère que le générateur n'utilise pas.
  ///
  /// \p{L} couvre toutes les écritures : sans cela « É » aurait été compté
  /// comme un symbole, et « Été2026 » aurait satisfait la règle sans en
  /// contenir un seul.
  static bool _contientSymbole(String value) =>
      value.contains(RegExp(r'[^\p{L}\p{N}\s]', unicode: true));

  /// Mot de passe conforme, tiré de [Random.secure].
  ///
  /// Une classe requise est placée d'abord, puis le reste est complété au
  /// hasard et l'ensemble est mélangé : tirer simplement 16 caractères et
  /// espérer une majuscule laisserait passer, rarement, un mot de passe que la
  /// validation refuserait ensuite.
  static String generate({int length = generatedLength}) {
    if (length < minLength) {
      throw ArgumentError.value(length, 'length', 'doit valoir au moins $minLength');
    }
    final rnd = Random.secure();
    String pick(String source) => source[rnd.nextInt(source.length)];

    final chars = <String>[
      pick(_majuscules),
      pick(symboles),
      pick(_minuscules),
      pick(_chiffres),
      for (var i = 4; i < length; i++) pick(_alphabet),
    ];

    // Fisher-Yates sur la même source sûre, sinon les quatre premières
    // positions auraient toujours la même nature.
    for (var i = chars.length - 1; i > 0; i--) {
      final j = rnd.nextInt(i + 1);
      final tmp = chars[i];
      chars[i] = chars[j];
      chars[j] = tmp;
    }
    return chars.join();
  }
}
