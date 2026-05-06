import Foundation

enum Config {
    private static let infoPlist: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            return [:]
        }
        return dict
    }()

    static let supabaseURL: String = infoPlist["SUPABASE_URL"] as? String ?? "https://your-project.supabase.co"
    static let supabaseAnonKey: String = infoPlist["SUPABASE_ANON_KEY"] as? String ?? "your-anon-key"
    static let dailyAPIKey: String = infoPlist["DAILY_API_KEY"] as? String ?? ""
    static let dailyRoomBaseURL: String = infoPlist["DAILY_ROOM_BASE_URL"] as? String ?? "https://medlingo.daily.co"
    static let cloudKitContainerID: String = infoPlist["CLOUDKIT_CONTAINER_ID"] as? String ?? "iCloud.com.medlingo.app"
    static let awsBackupBucket: String = infoPlist["AWS_BACKUP_BUCKET"] as? String ?? "medlingo-backups"
    static let audioStorageBucket: String = "audio"
    static let mediaStorageBucket: String = "media"

    static let aiVideoProvider: String = infoPlist["AI_VIDEO_PROVIDER"] as? String ?? "heygen"
    static let aiVideoDefaultAvatarID: String = infoPlist["AI_VIDEO_DEFAULT_AVATAR_ID"] as? String ?? ""
    static let aiVideoDefaultVoiceID: String = infoPlist["AI_VIDEO_DEFAULT_VOICE_ID"] as? String ?? ""
}
