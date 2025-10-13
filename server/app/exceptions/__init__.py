"""
Custom exception classes for the application.

Provides a hierarchy of exceptions with consistent error codes and messages.
"""

from typing import Any, Optional


class AppException(Exception):
    """
    Base exception class for all application exceptions.
    
    All custom exceptions should inherit from this class to ensure
    consistent error handling and response formatting.
    """

    def __init__(
        self,
        message: str,
        code: str,
        status_code: int = 500,
        details: Optional[Any] = None,
    ):
        self.message = message
        self.code = code
        self.status_code = status_code
        self.details = details
        super().__init__(self.message)


class NotFoundException(AppException):
    """
    Exception raised when a requested resource is not found.
    
    Examples:
    - User not found
    - Gig not found
    - Transaction not found
    """

    def __init__(
        self,
        message: str = "Resource not found",
        details: Optional[Any] = None,
    ):
        super().__init__(
            message=message,
            code="NOT_FOUND",
            status_code=404,
            details=details,
        )


class UnauthorizedException(AppException):
    """
    Exception raised when authentication fails or is missing.
    
    Examples:
    - Invalid credentials
    - Missing authentication token
    - Expired token
    """

    def __init__(
        self,
        message: str = "Authentication required",
        details: Optional[Any] = None,
    ):
        super().__init__(
            message=message,
            code="UNAUTHORIZED",
            status_code=401,
            details=details,
        )


class ForbiddenException(AppException):
    """
    Exception raised when user lacks permission for an action.
    
    Examples:
    - Accessing another user's data
    - Performing admin-only actions
    - Modifying protected resources
    """

    def __init__(
        self,
        message: str = "Permission denied",
        details: Optional[Any] = None,
    ):
        super().__init__(
            message=message,
            code="FORBIDDEN",
            status_code=403,
            details=details,
        )


class ValidationException(AppException):
    """
    Exception raised when input validation fails.
    
    Examples:
    - Invalid email format
    - Missing required fields
    - Data constraint violations
    """

    def __init__(
        self,
        message: str = "Validation error",
        details: Optional[Any] = None,
    ):
        super().__init__(
            message=message,
            code="VALIDATION_ERROR",
            status_code=422,
            details=details,
        )


class ConflictException(AppException):
    """
    Exception raised when a resource conflict occurs.
    
    Examples:
    - Duplicate email registration
    - Concurrent modification
    - State conflicts
    """

    def __init__(
        self,
        message: str = "Resource conflict",
        details: Optional[Any] = None,
    ):
        super().__init__(
            message=message,
            code="CONFLICT",
            status_code=409,
            details=details,
        )


class DatabaseException(AppException):
    """
    Exception raised when database operations fail.
    
    Examples:
    - Connection failures
    - Transaction deadlocks
    - Constraint violations
    """

    def __init__(
        self,
        message: str = "Database operation failed",
        details: Optional[Any] = None,
    ):
        super().__init__(
            message=message,
            code="DATABASE_ERROR",
            status_code=500,
            details=details,
        )


class ExternalServiceException(AppException):
    """
    Exception raised when external service calls fail.
    
    Examples:
    - Payment gateway errors
    - SMS service failures
    - Email delivery issues
    """

    def __init__(
        self,
        message: str = "External service error",
        details: Optional[Any] = None,
    ):
        super().__init__(
            message=message,
            code="EXTERNAL_SERVICE_ERROR",
            status_code=502,
            details=details,
        )


class RateLimitException(AppException):
    """
    Exception raised when rate limit is exceeded.
    
    Examples:
    - Too many requests
    - API quota exceeded
    - Abuse prevention
    """

    def __init__(
        self,
        message: str = "Rate limit exceeded",
        details: Optional[Any] = None,
    ):
        super().__init__(
            message=message,
            code="RATE_LIMIT_EXCEEDED",
            status_code=429,
            details=details,
        )


class BadRequestException(AppException):
    """
    Exception raised when request is malformed or invalid.
    
    Examples:
    - Invalid JSON
    - Malformed request
    - Invalid parameters
    """

    def __init__(
        self,
        message: str = "Bad request",
        details: Optional[Any] = None,
    ):
        super().__init__(
            message=message,
            code="BAD_REQUEST",
            status_code=400,
            details=details,
        )
