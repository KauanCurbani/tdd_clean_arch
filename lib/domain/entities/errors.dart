sealed class DomainError {}

final class UnexpectedError extends DomainError {}

final class SessionExpiredError extends DomainError {}
