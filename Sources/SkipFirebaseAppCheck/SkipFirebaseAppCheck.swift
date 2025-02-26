// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
#if SKIP
import SkipFirebaseCore
import kotlinx.coroutines.tasks.await

// https://firebase.google.com/docs/reference/swift/firebaseappcheck/api/reference/Classes/AppCheck
// https://firebase.google.com/docs/reference/android/com/google/firebase/appcheck/FirebaseAppCheck

public final class AppCheck {
    public let appcheck: com.google.firebase.appcheck.FirebaseAppCheck

    public init(appcheck: com.google.firebase.appcheck.FirebaseAppCheck) {
        self.appcheck = appcheck
    }

    public static func appCheck() -> AppCheck {
        AppCheck(appcheck: com.google.firebase.appcheck.FirebaseAppCheck.getInstance())
    }

    public static func appCheck(app: FirebaseApp) -> AppCheck {
        AppCheck(appcheck: com.google.firebase.appcheck.FirebaseAppCheck.getInstance(app.app))
    }
}
#endif
#endif
