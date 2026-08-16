// Precomputed credentials for the demo account.
//
// The hash used to be derived at runtime, inside the very first
// `AppDatabase.open()` — a full PBKDF2 run (~860 ms of pure Dart) charged to
// whoever opened the app first, on top of the run needed to check the password
// they had just typed. Baking it in makes first launch cost nothing extra.
//
// Publishing the hash is not a leak: the account, its address and its password
// are all documented demo fixtures. It exists so the app has something to sign
// in with, not to protect anything.
//
// Regenerate with `PasswordHasher.hash(kSeedPassword, PasswordHasher.newSalt())`
// if the seed password or `defaultIterations` ever changes — a mismatch shows
// up immediately as `seed_credentials_test.dart` failing.
const kSeedSalt = 'olFe9gPT9t39bP6UXL0/Uw==';
const kSeedHash = 'Fa9OdRbwubFK6lAZQxUjnyE+Bxb09Af0qDW8HmaAlTs=';
