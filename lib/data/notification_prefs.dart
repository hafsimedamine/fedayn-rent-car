// What the app is allowed to send, and through which channel.

/// User-controlled notification settings.
///
/// Immutable: the screen builds a new one per change and hands it to
/// [AppState], which persists it. That keeps "what is on screen" and "what is
/// stored" from drifting apart.
class NotificationPrefs {
  const NotificationPrefs({
    this.push = true,
    this.email = true,
    this.sms = false,
    this.bookingUpdates = true,
    this.pickupReminders = true,
    this.returnReminders = true,
    this.availabilityAlerts = true,
    this.priceDrops = false,
    this.newOffers = false,
    this.promoEmails = false,
    this.quietHours = true,
  });

  // ── Channels ──
  final bool push;
  final bool email;
  final bool sms;

  // ── Réservations (transactional) ──
  final bool bookingUpdates;
  final bool pickupReminders;
  final bool returnReminders;

  // ── Voitures ──
  /// A saved car going from "louée" back to available.
  final bool availabilityAlerts;
  final bool priceDrops;

  // ── Marketing ──
  final bool newOffers;
  final bool promoEmails;

  /// Holds non-urgent notifications back between 22 h and 7 h. Booking
  /// updates are urgent and go out regardless, which the screen says.
  final bool quietHours;

  /// True when nothing can actually be delivered — worth warning about
  /// rather than letting the topic switches look effective.
  bool get allChannelsOff => !push && !email && !sms;

  NotificationPrefs copyWith({
    bool? push,
    bool? email,
    bool? sms,
    bool? bookingUpdates,
    bool? pickupReminders,
    bool? returnReminders,
    bool? availabilityAlerts,
    bool? priceDrops,
    bool? newOffers,
    bool? promoEmails,
    bool? quietHours,
  }) =>
      NotificationPrefs(
        push: push ?? this.push,
        email: email ?? this.email,
        sms: sms ?? this.sms,
        bookingUpdates: bookingUpdates ?? this.bookingUpdates,
        pickupReminders: pickupReminders ?? this.pickupReminders,
        returnReminders: returnReminders ?? this.returnReminders,
        availabilityAlerts: availabilityAlerts ?? this.availabilityAlerts,
        priceDrops: priceDrops ?? this.priceDrops,
        newOffers: newOffers ?? this.newOffers,
        promoEmails: promoEmails ?? this.promoEmails,
        quietHours: quietHours ?? this.quietHours,
      );

  Map<String, String> toMap() => {
        'notif.push': '$push',
        'notif.email': '$email',
        'notif.sms': '$sms',
        'notif.bookingUpdates': '$bookingUpdates',
        'notif.pickupReminders': '$pickupReminders',
        'notif.returnReminders': '$returnReminders',
        'notif.availabilityAlerts': '$availabilityAlerts',
        'notif.priceDrops': '$priceDrops',
        'notif.newOffers': '$newOffers',
        'notif.promoEmails': '$promoEmails',
        'notif.quietHours': '$quietHours',
      };

  /// Reads what is stored, falling back to the default for anything absent —
  /// so a preference added in a later version does not need a migration.
  factory NotificationPrefs.fromMap(Map<String, String> stored) {
    const fallback = NotificationPrefs();
    bool read(String key, bool orElse) => switch (stored['notif.$key']) {
          'true' => true,
          'false' => false,
          _ => orElse,
        };
    return NotificationPrefs(
      push: read('push', fallback.push),
      email: read('email', fallback.email),
      sms: read('sms', fallback.sms),
      bookingUpdates: read('bookingUpdates', fallback.bookingUpdates),
      pickupReminders: read('pickupReminders', fallback.pickupReminders),
      returnReminders: read('returnReminders', fallback.returnReminders),
      availabilityAlerts: read('availabilityAlerts', fallback.availabilityAlerts),
      priceDrops: read('priceDrops', fallback.priceDrops),
      newOffers: read('newOffers', fallback.newOffers),
      promoEmails: read('promoEmails', fallback.promoEmails),
      quietHours: read('quietHours', fallback.quietHours),
    );
  }
}
