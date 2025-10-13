"""
Global exception handler middleware.

Catches all unhandled exceptions and returns consistent error responses
with proper logging and security considerations.
"""

from datetime import datetime, timezone
from typing import Union

from fastapi import Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.exceptions import AppException
from app.middleware.request_id import get_request_id
from app.utils.logger import get_logger
from app.configs.app_config import app_config

logger = get_logger(__name__)


def create_error_response(
    code: str,
    message: str,
    status_code: int,
    path: str,
    error_name: str = None,
    details: Union[dict, list, None] = None,
) -> JSONResponse:
    """
    Create a standardized error response in NestJS/Spring Boot style.

    Args:
        code: Error code (e.g., "NOT_FOUND", "VALIDATION_ERROR")
        message: Human-readable error message
        status_code: HTTP status code
        path: Request path that caused the error
        error_name: HTTP error name (e.g., "Not Found", "Internal Server Error")
        details: Optional additional error details

    Returns:
        JSONResponse with standardized error format
    """
    request_id = get_request_id() or "no-request-id"

    # Generate error name from status code if not provided
    if error_name is None:
        status_code_to_name = {
            400: "Bad Request",
            401: "Unauthorized",
            403: "Forbidden",
            404: "Not Found",
            405: "Method Not Allowed",
            409: "Conflict",
            422: "Unprocessable Entity",
            429: "Too Many Requests",
            500: "Internal Server Error",
            502: "Bad Gateway",
            503: "Service Unavailable",
        }
        error_name = status_code_to_name.get(status_code, "Error")

    error_response = {
        "statusCode": status_code,
        "error": error_name,
        "message": message,
        "path": path,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "request_id": request_id,
    }

    # Only include details if present and not in production
    if details is not None:
        if app_config.ENVIRONMENT == "production":
            # In production, sanitize details
            if isinstance(details, dict):
                sanitized = {
                    k: v for k, v in details.items() if k not in ["stack_trace", "internal"]
                }
                if sanitized:  # Only add if there's something left after sanitization
                    error_response["details"] = sanitized
            # Don't add details for lists in production
        else:
            error_response["details"] = details

    return JSONResponse(
        status_code=status_code,
        content=error_response,
    )


async def app_exception_handler(request: Request, exc: AppException) -> JSONResponse:
    """
    Handle custom application exceptions.

    Args:
        request: The request that caused the exception
        exc: The AppException instance

    Returns:
        Standardized error response
    """
    # Log the error with context
    logger.error(
        f"Application error: {exc.code} - {exc.message}",
        extra={
            "error_code": exc.code,
            "status_code": exc.status_code,
            "details": exc.details,
            "path": request.url.path,
            "method": request.method,
        },
    )

    return create_error_response(
        code=exc.code,
        message=exc.message,
        status_code=exc.status_code,
        path=request.url.path,
        details=exc.details,
    )


async def http_exception_handler(
    request: Request, exc: StarletteHTTPException
) -> JSONResponse:
    """
    Handle Starlette/FastAPI HTTP exceptions.

    Args:
        request: The request that caused the exception
        exc: The HTTPException instance

    Returns:
        Standardized error response
    """
    # Map status codes to error codes
    status_code_to_error_code = {
        400: "BAD_REQUEST",
        401: "UNAUTHORIZED",
        403: "FORBIDDEN",
        404: "NOT_FOUND",
        405: "METHOD_NOT_ALLOWED",
        409: "CONFLICT",
        422: "VALIDATION_ERROR",
        429: "RATE_LIMIT_EXCEEDED",
        500: "INTERNAL_SERVER_ERROR",
        502: "BAD_GATEWAY",
        503: "SERVICE_UNAVAILABLE",
    }

    error_code = status_code_to_error_code.get(exc.status_code, "HTTP_ERROR")

    # Log the error
    log_level = "error" if exc.status_code >= 500 else "warning"
    getattr(logger, log_level)(
        f"HTTP error: {exc.status_code} - {exc.detail}",
        extra={
            "status_code": exc.status_code,
            "detail": exc.detail,
            "path": request.url.path,
            "method": request.method,
        },
    )

    return create_error_response(
        code=error_code,
        message=str(exc.detail),
        status_code=exc.status_code,
        path=request.url.path,
    )


async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    """
    Handle Pydantic validation errors.

    Args:
        request: The request that caused the exception
        exc: The RequestValidationError instance

    Returns:
        Standardized error response with validation details
    """
    # Format validation errors
    errors = []
    for error in exc.errors():
        field = ".".join(str(loc) for loc in error["loc"])
        errors.append({
            "field": field,
            "message": error["msg"],
            "type": error["type"],
        })

    # Log validation error
    logger.warning(
        f"Validation error: {len(errors)} field(s) failed validation",
        extra={
            "errors": errors,
            "path": request.url.path,
            "method": request.method,
        },
    )

    return create_error_response(
        code="VALIDATION_ERROR",
        message="Request validation failed",
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        path=request.url.path,
        details={"errors": errors},
    )


async def sqlalchemy_exception_handler(
    request: Request, exc: SQLAlchemyError
) -> JSONResponse:
    """
    Handle SQLAlchemy database errors.

    Args:
        request: The request that caused the exception
        exc: The SQLAlchemyError instance

    Returns:
        Standardized error response
    """
    # Log the database error with full details
    logger.error(
        f"Database error: {type(exc).__name__}",
        extra={
            "error_type": type(exc).__name__,
            "error_message": str(exc),
            "path": request.url.path,
            "method": request.method,
        },
        exc_info=True,
    )

    # Return sanitized error to client
    if app_config.ENVIRONMENT == "production":
        message = "A database error occurred. Please try again later."
        details = None
    else:
        message = f"Database error: {type(exc).__name__}"
        details = {"message": str(exc)[:200]}  # Limit error message length

    return create_error_response(
        code="DATABASE_ERROR",
        message=message,
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        path=request.url.path,
        details=details,
    )


async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """
    Handle all unhandled exceptions.

    Args:
        request: The request that caused the exception
        exc: The Exception instance

    Returns:
        Standardized error response
    """
    # Log the unexpected error with full stack trace
    logger.error(
        f"Unhandled exception: {type(exc).__name__} - {str(exc)}",
        extra={
            "error_type": type(exc).__name__,
            "error_message": str(exc),
            "path": request.url.path,
            "method": request.method,
        },
        exc_info=True,
    )

    # Return generic error to client
    if app_config.ENVIRONMENT == "production":
        message = "An unexpected error occurred. Please try again later."
        details = None
    else:
        message = f"Internal server error: {type(exc).__name__}"
        details = {
            "message": str(exc),
            "type": type(exc).__name__,
        }

    return create_error_response(
        code="INTERNAL_SERVER_ERROR",
        message=message,
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        path=request.url.path,
        details=details,
    )
