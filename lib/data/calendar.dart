// Dates réelles, en français.
//
// Le prototype figeait le calendrier sur juillet 2026 : une grille de 31 jours
// démarrant un mercredi, un « aujourd'hui » constant à 13, et les libellés
// écrivaient « juil. » en dur. Tout part maintenant de DateTime.

const kMoisFr = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

/// Abréviations telles qu'on les écrit en français : « juin » et « août » ne
/// s'abrègent pas, et « sept. » prend quatre lettres.
const kMoisCourtFr = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

/// La semaine commence le lundi.
const kJoursCourtsFr = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

/// Minuit, pour comparer des jours sans se faire piéger par l'heure.
DateTime jourSeul(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime get aujourdHui => jourSeul(DateTime.now());

int joursDansLeMois(int annee, int mois) => DateTime(annee, mois + 1, 0).day;

/// Position du 1er du mois dans une semaine commençant le lundi (0 = lundi).
int decalagePremierJour(int annee, int mois) => DateTime(annee, mois, 1).weekday - 1;

/// « 14 juillet »
String formatJourMois(DateTime d) => '${d.day} ${kMoisFr[d.month - 1]}';

/// « 14 juil. »
String formatCourt(DateTime d) => '${d.day} ${kMoisCourtFr[d.month - 1]}';

/// « 14 juillet 2026 »
String formatComplet(DateTime d) => '${formatJourMois(d)} ${d.year}';

/// « 14 juil. – 18 juil. », en n'écrivant le mois qu'une fois s'il est le même.
String formatPeriode(DateTime debut, DateTime fin) {
  if (debut.year == fin.year && debut.month == fin.month) {
    return '${debut.day} – ${formatCourt(fin)}';
  }
  return '${formatCourt(debut)} – ${formatCourt(fin)}';
}

String formatDuree(int jours) => '$jours jour${jours > 1 ? 's' : ''}';

/// Nombre de nuits entre deux jours.
int nuitsEntre(DateTime debut, DateTime fin) => jourSeul(fin).difference(jourSeul(debut)).inDays;

/// Tous les jours de [debut] à [fin] inclus.
List<DateTime> joursDe(DateTime debut, DateTime fin) {
  final d = jourSeul(debut);
  final f = jourSeul(fin);
  return [for (var i = 0; i <= f.difference(d).inDays; i++) DateTime(d.year, d.month, d.day + i)];
}

/// Le mois de [d], décalé de [delta] mois, normalisé au 1er.
DateTime moisDecale(DateTime d, int delta) => DateTime(d.year, d.month + delta, 1);

/// Deux dates tombent-elles le même jour ?
bool memeJour(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
