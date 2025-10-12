"""
Logging middleware for request/response tracking.

Logs all incoming requests and outgoing responses with timing information,
status codes, and contextual data.
"""

import time
from typing import Callable

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from app.utils.logger import get_logger

logger = get_logger(__name__)


class LoggingMiddleware(BaseHTTPMiddleware):
    """
    Middleware that logs HTTP requests and responses.

    Logs:
    - Request method, path, query parameters
    - Response status code
    - Request duration
    - User agent and client IP
    """

    async def dispatch(
        self, request: Request, call_next: Callable
    ) -> Response:
        # Start timing
        start_time = time.time()

        # Extract request details
        method = request.method
        path = request.url.path
        query_params = dict(request.query_params)
        client_ip = request.client.host if request.client else "unknown"
        user_agent = request.headers.get("user-agent", "unknown")

        # Get context for logging
        from app.middleware.request_id import get_request_id, get_user_id
        request_id = get_request_id()
        user_id = get_user_id()
        
        # Build context string
        context_parts = []
        if request_id and request_id != "no-request-id":
            context_parts.append(f"req={request_id[:8]}")
        if user_id and user_id != "anonymous":
            context_parts.append(f"user={user_id[:8]}")
        
        context_prefix = f"[{' '.join(context_parts)}] " if context_parts else ""

        # Log incoming request
        logger.info(
            f"{context_prefix}Request started: {method} {path}",
            extra={
                "method": method,
                "path": path,
                "query_params": query_params,
                "client_ip": client_ip,
                "user_agent": user_agent,
            },
        )

        # Process request
        try:
            response = await call_next(request)
        except Exception as e:
            # Calculate duration
            duration_ms = (time.time() - start_time) * 1000

            # Log error
            logger.error(
                f"{context_prefix}Request failed: {method} {path} - {str(e)}",
                extra={
                    "method": method,
                    "path": path,
                    "duration_ms": round(duration_ms, 2),
                    "error": str(e),
                },
                exc_info=True,
            )
            raise

        # Calculate duration
        duration_ms = (time.time() - start_time) * 1000

        # Log response
        log_level = "error" if response.status_code >= 500 else "warning" if response.status_code >= 400 else "info"
        
        getattr(logger, log_level)(
            f"{context_prefix}Request completed: {method} {path} - {response.status_code}",
            extra={
                "method": method,
                "path": path,
                "status_code": response.status_code,
                "duration_ms": round(duration_ms, 2),
            },
        )

        return response
