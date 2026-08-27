import Foundation
import CryptoKit

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "That email and password don't match our records."
        case .emailAlreadyInUse: return "An account with that email already exists. Try signing in instead."
        case .weakPassword: return "Please use a password with at least 6 characters."
        case .invalidEmail: return "Please enter a valid email address."
        }
    }
}

protocol AuthService {
    func signUp(email: String, password: String, displayName: String) async throws -> UserAccount
    func signIn(email: String, password: String) async throws -> UserAccount
    func signOut()
    /// Apple requires that any app offering account creation also offer
    /// in-app account deletion (App Review Guideline 5.1.1(v)) — this isn't
    /// optional polish, it's a rejection reason if missing.
    func deleteAccount(email: String) async throws
}

/// Local, on-device account store — good enough to demo a real sign-up/sign-in
/// gate, but **not** how you'd ship this. Passwords never leave the device here,
/// which sounds safe but actually means there's no real account recovery, no
/// protection if the device's UserDefaults are read by another process, and no
/// way to log into the same account on a second device. For production, swap
/// this for a real auth backend (Firebase Auth, Supabase Auth, or your own
/// server) — same pattern as `BriefService`'s Mock/Remote split.
struct MockAuthService: AuthService {
    private struct StoredAccount: Codable {
        let account: UserAccount
        let passwordHash: String
    }

    private let storageKey = "com.newsu.localAccounts"
    private let defaults = UserDefaults.standard

    private func loadAccounts() -> [String: StoredAccount] {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: StoredAccount].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveAccounts(_ accounts: [String: StoredAccount]) {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func hash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    func signUp(email: String, password: String, displayName: String) async throws -> UserAccount {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalizedEmail.contains("@"), normalizedEmail.contains(".") else {
            throw AuthError.invalidEmail
        }
        guard password.count >= 6 else { throw AuthError.weakPassword }

        var accounts = loadAccounts()
        guard accounts[normalizedEmail] == nil else { throw AuthError.emailAlreadyInUse }

        let account = UserAccount(id: UUID().uuidString, email: normalizedEmail, displayName: displayName)
        accounts[normalizedEmail] = StoredAccount(account: account, passwordHash: hash(password))
        saveAccounts(accounts)
        return account
    }

    func signIn(email: String, password: String) async throws -> UserAccount {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let accounts = loadAccounts()
        guard let stored = accounts[normalizedEmail], stored.passwordHash == hash(password) else {
            throw AuthError.invalidCredentials
        }
        return stored.account
    }

    func signOut() {
        // Nothing to invalidate locally — session state lives in AppState/PersistenceService.
    }

    func deleteAccount(email: String) async throws {
        var accounts = loadAccounts()
        accounts.removeValue(forKey: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        saveAccounts(accounts)
    }
}

/// Production implementation: talks to your real auth backend. Wire this up
/// once you have one, and swap it in for `MockAuthService` in `AppState`.
struct RemoteAuthService: AuthService {
    var baseURL: URL

    func signUp(email: String, password: String, displayName: String) async throws -> UserAccount {
        // POST to `${baseURL}/auth/signup`, decode the created account.
        throw AuthError.invalidCredentials
    }

    func signIn(email: String, password: String) async throws -> UserAccount {
        // POST to `${baseURL}/auth/signin`, decode the returned account + session token.
        throw AuthError.invalidCredentials
    }

    func signOut() {
        // Invalidate the session token server-side / clear it from the Keychain.
    }

    func deleteAccount(email: String) async throws {
        // DELETE to `${baseURL}/auth/account` — must actually erase the user's
        // data server-side too, not just the client session, per Apple's
        // requirement that deletion be genuine, not a soft-disable.
    }
}
