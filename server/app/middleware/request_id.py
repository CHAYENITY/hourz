"""
Request ID middleware for distributed tracing.

Generates a unique request ID for each incoming request and propagates it
through the entire request lifecycle for logging and debugging.
"""

import uuid
from contextvars import ContextVar
from typing import Callable, Optional

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

# Context variables for storing request-scoped data
_request_id_ctx_var: ContextVar[Optional[str]] = ContextVar(
    "request_id", default=None
)
_user_id_ctx_var: ContextVar[Optional[str]] = ContextVar("user_id", default=None)


def get_request_id() -> Optional[str]:
    """Get the current request ID from context."""
    return _request_id_ctx_var.get()


def set_request_id(request_id: str) -> None:
    """Set the request ID in context."""
    _request_id_ctx_var.set(request_id)


def get_user_id() -> Optional[str]:
    """Get the current user ID from context."""
    return _user_id_ctx_var.get()


def set_user_id(user_id: str) -> None:
    """Set the user ID in context."""
    _user_id_ctx_var.set(user_id)


class RequestIdMiddleware(BaseHTTPMiddleware):
    """
    Middleware that generates and propagates request IDs.

    For each incoming request:
    1. Checks for existing X-Request-ID header
    2. Generates a new UUID if not present
    3. Stores in context variables for logging
    4. Adds to response headers for client tracing
    """

    async def dispatch(
        self, request: Request, call_next: Callable
    ) -> Response:
        # Get or generate request ID
        request_id = request.headers.get("X-Request-ID") or str(uuid.uuid4())

        # Store in context for logging
        set_request_id(request_id)

        # Try to extract user ID from request state (set by auth middleware)
        if hasattr(request.state, "user_id"):
            set_user_id(str(request.state.user_id))

        # Process request
        response = await call_next(request)

        # Add request ID to response headers
        response.headers["X-Request-ID"] = request_id

        return response
