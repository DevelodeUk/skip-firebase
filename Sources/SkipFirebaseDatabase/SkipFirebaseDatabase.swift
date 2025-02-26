// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
#if SKIP
import SkipFirebaseCore
import kotlinx.coroutines.tasks.await

// https://firebase.google.com/docs/reference/swift/firebasedatabase/api/reference/Classes/Database
// https://firebase.google.com/docs/reference/android/com/google/firebase/database/FirebaseDatabase

/// A wrapper for Firebase Realtime Database.
public final class Database {
    public let database: com.google.firebase.database.FirebaseDatabase

    public init(database: com.google.firebase.database.FirebaseDatabase) {
        self.database = database
    }

    public static func database() -> Database {
        Database(database: com.google.firebase.database.FirebaseDatabase.getInstance())
    }

    public static func database(app: FirebaseApp) -> Database {
        Database(database: com.google.firebase.database.FirebaseDatabase.getInstance(app.app))
    }
    
    /// Returns the root database reference.
    public func reference() -> DatabaseReference {
        return DatabaseReference(ref: database.getReference())
    }
}

// MARK: - DatabaseReference

/// A wrapper for a DatabaseReference.
public class DatabaseReference: KotlinConverting<com.google.firebase.database.DatabaseReference> {
    public let ref: com.google.firebase.database.DatabaseReference

    public init(ref: com.google.firebase.database.DatabaseReference) {
        self.ref = ref
    }

    public override func kotlin(nocopy: Bool = false) -> com.google.firebase.database.DatabaseReference {
        return ref
    }

    public var description: String {
        return ref.toString()
    }
    
    /// Returns a reference to the child at the given path.
    public func child(_ path: String) -> DatabaseReference {
        return DatabaseReference(ref: ref.child(path))
    }
    
    /// Sets the value at this location.
    public func setValue(_ value: Any) async throws {
        try ref.setValue(value.kotlin()).await()
    }
    
    /// Updates the children at this location with the given values.
    public func updateChildValues(_ values: [String: Any]) async throws {
        try ref.updateChildValues(values.kotlin()).await()
    }
    
    /// Removes the value at this location.
    public func removeValue() async throws {
        try ref.removeValue().await()
    }
    
    /// Observes value events continuously.
    ///
    /// - Parameter block: A closure called with a DataSnapshot when data changes or with an error.
    /// - Returns: A handle that can be used to remove the observer.
    public func observeValue(with block: @escaping (DataSnapshot?, Error?) -> Void) -> DatabaseHandle {
        let listener = ValueEventListenerWrapper(
            onDataChange: { snapshot in
                block(DataSnapshot(snapshot: snapshot), nil)
            },
            onCancelled: { error in
                block(nil, error)
            }
        )
        ref.addValueEventListener(listener)
        return DatabaseHandle(listener: listener, reference: self)
    }
    
    /// Observes a single value event.
    ///
    /// - Parameter block: A closure called with a DataSnapshot when data is retrieved or with an error.
    public func observeSingleEvent(with block: @escaping (DataSnapshot?, Error?) -> Void) {
        let listener = ValueEventListenerWrapper(
            onDataChange: { snapshot in
                block(DataSnapshot(snapshot: snapshot), nil)
            },
            onCancelled: { error in
                block(nil, error)
            }
        )
        ref.addListenerForSingleValueEvent(listener)
    }
    
    /// Removes a previously added observer.
    public func removeObserver(handle: DatabaseHandle) {
        ref.removeEventListener(handle.listener)
    }
}

// MARK: - ValueEventListener Wrapper

/// A wrapper that implements the ValueEventListener interface.
public class ValueEventListenerWrapper: NSObject, com.google.firebase.database.ValueEventListener {
    private let onDataChangeBlock: (com.google.firebase.database.DataSnapshot) -> Void
    private let onCancelledBlock: (com.google.firebase.database.DatabaseError) -> Void

    public init(onDataChange: @escaping (com.google.firebase.database.DataSnapshot) -> Void,
                onCancelled: @escaping (com.google.firebase.database.DatabaseError) -> Void) {
        self.onDataChangeBlock = onDataChange
        self.onCancelledBlock = onCancelled
    }
    
    public func onDataChange(_ snapshot: com.google.firebase.database.DataSnapshot) {
        onDataChangeBlock(snapshot)
    }
    
    public func onCancelled(_ error: com.google.firebase.database.DatabaseError) {
        onCancelledBlock(error)
    }
}

// MARK: - DatabaseHandle

/// A handle for a registered database observer.
public class DatabaseHandle {
    public let listener: com.google.firebase.database.ValueEventListener
    public let reference: DatabaseReference

    public init(listener: com.google.firebase.database.ValueEventListener, reference: DatabaseReference) {
        self.listener = listener
        self.reference = reference
    }
}

// MARK: - DataSnapshot

/// A wrapper for a DataSnapshot.
public class DataSnapshot: KotlinConverting<com.google.firebase.database.DataSnapshot> {
    public let snapshot: com.google.firebase.database.DataSnapshot

    public init(snapshot: com.google.firebase.database.DataSnapshot) {
        self.snapshot = snapshot
    }

    public override func kotlin(nocopy: Bool = false) -> com.google.firebase.database.DataSnapshot {
        return snapshot
    }

    /// Indicates whether data exists at this snapshot.
    public var exists: Bool {
        return snapshot.exists()
    }
    
    /// Returns the data stored at this snapshot.
    public var value: Any? {
        return deepSwift(value: snapshot.getValue())
    }
    
    /// Returns a snapshot for the child at the specified path.
    public func child(_ path: String) -> DataSnapshot {
        return DataSnapshot(snapshot: snapshot.child(path))
    }
}
#endif
#endif
