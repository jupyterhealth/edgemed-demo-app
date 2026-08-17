# AGP 9 / R8 full mode strips no-arg constructors that Room and WorkManager
# instantiate via reflection (WorkDatabase_Impl, InputMergers, etc.).
# Without these keeps, release builds crash at startup in InitializationProvider:
# "Failed to create an instance of class androidx.work.impl.WorkDatabase.canonicalName"

-keep class * extends androidx.room.RoomDatabase {
    <init>();
    public ** createInvalidationTracker();
    public void clearAllTables();
}
-keep class androidx.room.RoomDatabase$JournalMode { *; }

# `{ *; }` does not keep constructors; WorkManager needs them for Class.newInstance().
-keep class androidx.work.** {
    <init>(...);
}
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}
