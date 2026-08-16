# Fedayn's Rent Car — Flutter app

A Flutter implementation of the Claude Design prototype in `../project/`
(`Fedayn's Auth Flow.dc.html`). The app is French-only, prices are in Moroccan
Dirham, and the layout targets a 390×844 phone.

## Running it

```bash
flutter pub get
flutter run --release      # see the note below before using plain `flutter run`
```

**Use `--release` (or `--profile`) when judging how it performs.** Plain
`flutter run` builds in debug: unoptimised, every assertion live, JIT-compiled
as it goes. Typing lag and sluggish transitions in a debug build are the debug
build, not the app.

Requires **Flutter 3.6+** (`Color.withValues` and current Material APIs).
Verified against Flutter 3.44.9 / Dart 3.12.2.

Platform folders for **Android**, **iOS** and **web** are checked in. Only the
web build was compiled during development — this project was built in a Linux
container with no Android SDK and no Xcode, so those two targets are unverified
and may need the usual first-run signing/SDK setup.

```bash
flutter test          # 164 tests
flutter analyze       # clean
flutter build web --release
```

## Layout

```
lib/
├── main.dart              app entry + AppScope
├── theme.dart             colours, radii, type scale (lifted from the prototype)
├── data/
│   ├── models.dart        Car, CarSpec, Agency, Booking, SavedCard, CapturedPhoto
│   ├── notification_prefs.dart  what the app may send, and through which channel
│   ├── fleet.dart         fleet, specs, agencies, bookings, FR display helpers
│   └── db/                SQLite accounts — see "Accounts & SQL"
├── state/app_state.dart   ChangeNotifier: session, favourites, profile, booking draft
├── widgets/               field, car card, buttons, photo picker, common chrome
└── screens/
    ├── welcome · login · register · forgot_password
    ├── verify_cin · verify_license · success
    ├── main_shell + tabs/ (home · rentals · saved · account)
    ├── car_detail · booking/ (dates · review · payment · processing · confirm)
    ├── booking_details · modals
    └── account/ (personal_info · my_documents · notification_settings ·
                  payment_methods · contact_us)
```

## Demo data & how to exercise it

Accounts are stored for real (see below). Everything else — documents,
bookings, payments — is still a fixture, defined at the bottom of
`lib/data/fleet.dart` and in `lib/state/app_state.dart`. They are deliberately
synthetic: `example.com` is the domain RFC 2606 reserves for documentation, and
the document numbers are well-formed but invented.

| | Value |
|---|---|
| Fallback profile (before sign-in) | `Test User` · `user@example.com` · `+212 600 000 000` |
| CIN returned by a scan/upload | `TU 123456`, born `01/01/1990`, expires `01/01/2032` |
| Licence returned by a scan/upload | `19/123456`, issued `15/06/2015`, expires `15/06/2035` |
| Saved cards | `VISA •••• 3456` (default), `MC •••• 8821` |

### Signing in

A demo account is ensured on **every** app launch, so you can sign in
immediately:

| | |
|---|---|
| **Email** | `moncef@gmail.com` |
| **Password** | `12345678` |
| Name / phone | Mohamed Moncef · 06555555 |

It is inserted on every `AppDatabase.open()`, not just when the file is first
created. `onCreate` fires once in the lifetime of a database, so seeding from
there meant any install whose database predated the demo account never got it
and never could — a reinstall was the only way out. The insert is
`INSERT OR IGNORE`, so it is a no-op once the row exists and it will never
overwrite a real account that has claimed that address.
`seed_on_open_test.dart` walks that history: a database created without the
account, then a normal open.

Accounts are otherwise **real** — see *Accounts & SQL*. Register your own and
sign in with it; an unknown email or a wrong password is refused. Registration
requires a full name (two words), a valid email, 8+ digits of phone, an 8+
character password, and the terms box ticked.

### Things that only look real

- **Photo capture is real, the reading of it is not.** *Prendre une photo*
  opens the camera and *Importer une photo* opens the gallery, and the photo
  you choose is kept and shown as the thumbnail. The same picker
  (`widgets/photo_picker.dart`) is behind the camera badge on the account
  avatar, which sets a profile picture shown on Compte and Home. There is no
  OCR behind it, so
  the extracted fields are the fixtures above, marked *Auto-rempli*.
  iOS carries the two usage strings in `Info.plist`. Android deliberately
  declares **no** camera permission: `image_picker` goes through the system
  capture intent, and declaring `CAMERA` would make Android require it to be
  granted at runtime — which the plugin never requests, so capture would fail.
  Android can also kill the activity while the camera is open, so both screens
  call `retrieveLostData` on the way back in.
- **Payment** — the card form validates properly (16 digits, Luhn *not*
  checked, 3-digit CVV, future expiry, letters-only cardholder) but nothing is
  charged. `Paiement à la prise en charge` skips the card entirely.
- **Promo code** — `WEEK20` is the only code that applies (−20% on the base).
- **Booking calendar** — July 2026, with the 16th, 17th and 26th–28th held as
  already booked so the date-conflict warning can be triggered.

### Verification can be skipped — but it locks renting

Both document steps offer skipping in two places — *Passer* in the step header
and *Passer pour l'instant* under the form. The header one exists because the
other is the last widget on a long scrolling form, so on a 390×844 phone it is
below the fold and the step looks mandatory; `skip_reachable_test.dart` asserts
a skip is on screen without scrolling.

Skipping lands you in the app, but until **both** the CIN and the driving
licence are supplied:

- a *Location bloquée* reminder sits at the top of Home and resumes the flow
  when tapped;
- *Réserver* on any car opens a blocking sheet naming what is still missing
  instead of starting checkout.

`AppState.canRent` is the single gate. Verification status is **derived, never
stored**: `cinStatus` and `licenseStatus` are `VerifyState.missing` until that
document is actually supplied, and `verifyState` is only as good as the weaker
of the two. That is deliberate — the Account tab and Mes documents used to read
a fixture field and cheerfully showed *Vérifié* on an account that had uploaded
nothing. Nothing may report a document as approved that has not been sent.

`reviewOutcome` is the fixture toggle for what review *would* return; it cannot
promote a missing document.

### Prototype toggles

The design tool's preview props survive as fields on `AppState`. Set them
before `runApp` (or from a debug menu) to reach states that are otherwise hard
to produce:

| Field | Effect |
|---|---|
| `reviewOutcome` | `verified` / `pending` / `rejected` — the outcome review returns *once documents exist*. It cannot make an empty account look verified; with no documents every badge reads `missing`. |
| `rentalsEmpty` | empty state on the Rentals tab |
| `savedEmpty` | empty state on the Saved tab |
| `scanFailsFirstAttempt` | first document scan fails, showing the retry banner |
| `paymentDeclinesFirstAttempt` | first payment is declined, showing the retry screen |

## Accounts & SQL

Registration and sign-in run against **SQLite on the device** (`sqflite`).

```
lib/data/db/
├── app_database.dart            opens the file, owns the schema + migrations
├── account.dart                 the row, minus anything secret
├── auth_repository.dart         the interface + typed errors
├── sqlite_auth_repository.dart  the real implementation
├── in_memory_auth_repository.dart   web fallback (sqflite has no web support)
├── settings_store.dart          key/value interface + in-memory fallback
├── sqlite_settings_store.dart   the real implementation
└── password_hasher.dart         PBKDF2-HMAC-SHA256
```

```sql
CREATE TABLE users (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name           TEXT    NOT NULL,
  email               TEXT    NOT NULL UNIQUE COLLATE NOCASE,
  phone               TEXT    NOT NULL,
  password_hash       TEXT    NOT NULL,
  password_salt       TEXT    NOT NULL,
  password_iterations INTEGER NOT NULL,
  created_at          INTEGER NOT NULL
);

-- schema v2: device preferences (notification settings today)
CREATE TABLE settings (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

Points worth knowing before extending it:

- **Passwords are never stored.** Only a PBKDF2-HMAC-SHA256 key is, with a
  per-user 16-byte random salt and the iteration count alongside it, so the
  cost can be raised later without locking existing accounts out. The
  implementation is checked against published test vectors in
  `password_hasher_test.dart` — round-tripping alone would not prove it correct.
- **Hashing runs off the main isolate** via `compute`. It takes on the order of
  a second; inline it would visibly freeze the UI on sign-in.
- **Email is the login key**, normalised (trimmed, lowercased) in one place and
  `UNIQUE COLLATE NOCASE` in the schema. Duplicate registration relies on the
  constraint rather than a pre-check, which would race.
- **A wrong password and an unknown email fail identically**, so the response
  cannot be used to discover which addresses have accounts.
- **The web build cannot use SQLite.** `main.dart` picks the in-memory store
  when `kIsWeb`, so accounts there last only for the page session. Android,
  iOS, macOS, Windows and Linux persist.
- **Migrations are additive.** `schemaVersion` is 2; `onUpgrade` adds the
  `settings` table for anyone already on v1 rather than recreating the file, so
  existing accounts survive. Each future version adds its own step there.
- **Anything that must exist on every install goes in `open()`, not
  `onCreate`.** `onCreate` runs once per database file, so it cannot be used to
  introduce something to installs that already have one — that is what hid the
  demo account. Seeding is idempotent and runs on each open instead.
- **Notification preferences are stored, not remembered.** Every switch on
  Compte › Notifications writes through `SettingsStore`, and unknown or absent
  keys fall back to the default — so adding a preference needs no migration.
  Reads happen off the startup path; the screen shows defaults for the frame or
  two before they land.
- `users` and `settings` are what is in SQL so far. Bookings, favourites and
  documents are still in memory — extend `AppDatabase.createSchema` and add a
  repository beside these rather than reaching into the screens.

Swapping in a server later means writing one more `AuthRepository`
implementation and changing the line in `main.dart`; no screen needs to know.

## Narrow phones

The design mocks 390×844. A great many Android phones are **360×800**, and the
missing 30px is enough to break rows that merely looked tight in the mock — the
"Voitures disponibles" heading and its sort control needed 355px of the 316px
available, so they overflowed. `screens_render_test.dart` now renders every
screen at both sizes, and `narrow_layout_test.dart` additionally asserts that
nothing on a car card is ellipsised at 360 for any car in the fleet.

Where something did not fit, the fix is a layout that measures itself rather
than a hand-picked font size:

- the sort control sits on its own line under the heading, because no
  combination of sizes fits "Voitures disponibles" beside "Trier · Les plus
  populaires" at 360;
- the price row is a `Wrap`, so a four-figure price drops to a second line
  instead of eating the "Disponible" label — and still shares one line at 390;
- the spec line uses `BoxFit.scaleDown`, giving up a fraction of a point only
  on the one string that needs it rather than losing the fuel type;
- the car thumbnail is 96px instead of 110px below 370px wide.

## Performance notes

> **Run it in release or profile mode before judging how fast it is.**
> `flutter run` defaults to **debug**, which is unoptimised, keeps every
> assertion on, and JIT-compiles as it goes — typing lag and slow screen
> transitions there say nothing about the built app. Use
> `flutter run --release` (or `--profile`, which keeps the DevTools timeline)
> for anything performance-related.

**Typing must not rebuild the screen.** Each form used to wire every
`TextEditingController` to `setState(() {})` so its submit button could
re-evaluate — one character rebuilt ~183 widgets on Login and ~255 on
Register, plus every `AppField` re-running its validator. Now:

- `FormGate` (`widgets/form_gate.dart`) listens to the controllers and rebuilds
  the button alone, only when the enabled/disabled answer actually flips;
- `AppField` caches the error it is showing and only calls `setState` when that
  changes — which, while the field is focused, is never.

`typing_perf_test.dart` counts the rebuilds and fails if they climb back.
Ten keystrokes went from 1832 total widget builds to 524 on Login, and 2552 to
530 on Register; what remains is Flutter's own `EditableText`/`InputDecorator`.

**Nothing derives a key at launch.** The demo account's password hash is a
compile-time constant in `data/db/seed_credentials.dart`, so the first database
open no longer runs a full PBKDF2 pass (~860 ms) before the one needed to check
the password the user just typed. `seed_credentials_test.dart` asserts the
constant still matches what the hasher produces, so it cannot silently rot.

**The logo is 21 KB, not 193 KB.** It is the largest asset on almost every
screen. Resampled to 400px wide and quantised, it is visually identical at the
sizes it is actually drawn at (34–52 pt), and `BrandLogo` now decodes it at
exactly one source pixel per device pixel — it used to ask for twice that,
decoding four times the bitmap for no visible gain.

Four further things are deliberate, and each has a test in
`performance_test.dart` so they cannot be quietly undone:

- **The root only listens to the theme.** `MaterialApp` sits inside a
  `ValueListenableBuilder` on `themeModeListenable`, not an `AnimatedBuilder`
  on the whole state. Otherwise toggling one favourite rebuilt the entire tree.
- **The Home fleet list is lazy** — a `SliverList.separated`, so offscreen car
  cards are never built. It used to build all of them up front.
- **Car photos decode at display size.** The sources are ~800px wide; a 110px
  thumbnail passes `cacheWidth`, so the full bitmap is never held in memory.
  The logo does the same, which is what fixed it looking pixelated.
- **Password hashing runs on a background isolate.** It takes ~860ms; inline it
  would freeze the UI on every sign-in.

Anything that can take a perceptible moment goes through `runWithLoading`,
which puts up a blocking spinner and always takes it down again — on success,
on failure, and on the widget being disposed mid-flight. Two details in there
are load-bearing:

- **It waits for the spinner to paint before starting the work.** A dialog
  route only appears on the following frame; kicking off a second of key
  derivation in the same turn left the old screen on screen and the app read as
  frozen, which is exactly the complaint the overlay exists to answer.
- **Web has no isolates**, so `compute` would run the hash inline and block the
  frame. `PasswordHasher.hashAsync` takes a yielding path under `kIsWeb`
  instead, spreading the same derivation across event-loop turns. A test
  asserts the two paths produce byte-identical output — a divergence would mean
  an account created on one platform could not sign in on another.

## Tests

```bash
flutter test      # 164 tests
flutter analyze   # clean
```

Worth knowing about two of the files, since they exist to catch classes of bug
that a release build reports nothing about:

- `screens_render_test.dart` renders all 23 screens at **both 390×844 and
  360×800** and fails on any
  layout exception, which is how overflows get caught. **It loads the real
  bundled fonts first** — without that, the test font's fixed-width glyphs
  invent horizontal overflows that do not exist on a device. Any new test that
  asserts on layout should do the same.
- `auth_repository_test.dart` runs the real SQL against a real SQLite engine
  (in-memory, through `sqflite_common_ffi`) rather than a stub, so the schema
  and constraints are genuinely covered. Widget tests that touch the database
  must wrap those calls in `tester.runAsync` — `testWidgets` runs under a fake
  clock that real I/O never resolves inside.
- `theme_test.dart` asserts every text colour contrasts with the surface it is
  drawn on, in both themes. Dark mode broke twice by using a body-text colour
  as a background; this catches that.

`signup_flow_test.dart` and `navigation_test.dart` walk real journeys
(welcome → register → CIN → licence, and avatar → Account, log out → Login)
rather than pumping screens in isolation.

`loadAppFonts()` lives in `test/helpers.dart`; call it from `setUpAll` in any
test that asserts on layout or taps something positioned by text.

## Notes on the port

**Fonts are bundled, not fetched.** `google_fonts` resolves over the network on
first launch, which shows fallback type and fails offline. Inter and Poppins
ship in `assets/fonts/` instead. They are the Latin subsets, so any glyph
outside it — an emoji, a narrow no-break space — renders as a notdef box on
web, where there is no platform font to fall back to. Copy sticks to what the
subsets cover.

**Dark mode** is a `ThemeExtension` (`AppPalette`) holding every surface and
text colour, read through `context.p.<token>`. Brand constants that do not flip
— the accent orange, status colours, the navy hero — stay in `AppColors`. Note
`inverseSurface`/`onInverseSurface`: those are the filled "primary dark"
affordances (search filter button, small filled actions), which invert the
opposite way to body text. The Account tab's *Mode sombre* switch drives
`AppState.themeMode`.

**Sorting**: the Home filter button and the "Trier" label both open
`showSortSheet` — price ascending/descending, best rated, most reviewed and
newest (ranked on the spec sheet's vehicle age). It composes with the category
chips; see `AppState.visibleCars`.

**Prototype toggles** live on `AppState` (`verifyState`, `rentalsEmpty`,
`scanFailsFirstAttempt`, `paymentDeclinesFirstAttempt`). They correspond to the
design tool's preview props and drive the state variants — unverified-user
booking block, failed scan, declined payment, empty lists.

**Two deliberate departures from the prototype**, both following the brief's
intent over its literal output:

- the hero slot ships empty in the prototype; it uses a fleet photo here rather
  than rendering as a large void;
- the hero takes the prototype's 46% height only while the copy still fits, and
  the content scrolls rather than clipping on short viewports. The fixed 46%
  overflows at 844pt and worse with safe areas.

**Car images** are the real photos from `project/uploads/`, copied into
`assets/images/cars/`. The prototype's grey car-icon placeholder sits behind
each one as the loading/error state.
