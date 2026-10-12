/// Whether this build can receive push notifications.
///
/// The server half is built (ADR-043), but the app never registers a device,
/// so nothing a phone is "told" ever arrives. Every screen that would promise
/// a notification checks this first, so the app never claims one was sent.
/// Flip it in the same change that adds the app half of push.
const kPushOnPhones = false;
