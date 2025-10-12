"""
Structured logging configuration for the application.

Provides JSON logging for production and human-readable logs for development.
Includes context injection for request IDs, user IDs, and other metadata.
"""

import logging
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional

from pythonjsonlogger import jsonlogger


class ContextFilter(logging.Filter):
    """
    Inject contextual information into log records.
    
    This filter adds request_id, user_id, and other context from
    contextvars to every log record.
    """

    def filter(self, record: logging.LogRecord) -> bool:
        # Import here to avoid circular imports
        from app.middleware.request_id import get_request_id, get_user_id

        # Add request context to log record
        record.request_id = get_request_id() or "no-request-id"
        record.user_id = get_user_id() or "anonymous"

        return True


class CustomJsonFormatter(jsonlogger.JsonFormatter):
    """
    Custom JSON formatter for structured logging.
    
    Formats log records as JSON with additional fields like timestamp,
    request_id, user_id, and environment information.
    """

    def add_fields(
        self,
        log_record: dict[str, Any],
        record: logging.LogRecord,
        message_dict: dict[str, Any],
    ) -> None:
        super().add_fields(log_record, record, message_dict)

        # Add timestamp in ISO format with timezone
        log_record["timestamp"] = datetime.now(timezone.utc).isoformat()

        # Add log level
        log_record["level"] = record.levelname

        # Add logger name (module)
        log_record["logger"] = record.name

        # Add environment (lazy import to avoid circular dependency)
        try:
            from app.configs.app_config import app_config
            log_record["environment"] = app_config.ENVIRONMENT
        except ImportError:
            log_record["environment"] = "unknown"

        # Add request context (injected by ContextFilter)
        if hasattr(record, "request_id"):
            log_record["request_id"] = record.request_id
        if hasattr(record, "user_id"):
            log_record["user_id"] = record.user_id

        # Add exception info if present
        if record.exc_info:
            log_record["exception"] = self.formatException(record.exc_info)


class ColoredFormatter(logging.Formatter):
    """
    Colored formatter for development console output.
    
    Uses ANSI color codes to make logs more readable in the terminal.
    """

    # ANSI color codes
    COLORS = {
        "DEBUG": "\033[36m",  # Cyan
        "INFO": "\033[32m",  # Green
        "WARNING": "\033[33m",  # Yellow
        "ERROR": "\033[31m",  # Red
        "CRITICAL": "\033[35m",  # Magenta
    }
    RESET = "\033[0m"
    BOLD = "\033[1m"

    def format(self, record: logging.LogRecord) -> str:
        # Add color to level name
        level_color = self.COLORS.get(record.levelname, "")
        record.levelname = (
            f"{level_color}{self.BOLD}{record.levelname}{self.RESET}"
        )

        # Add context if available
        context_parts = []
        if hasattr(record, "request_id") and record.request_id != "no-request-id":
            context_parts.append(f"req={record.request_id[:8]}")
        if hasattr(record, "user_id") and record.user_id != "anonymous":
            context_parts.append(f"user={record.user_id[:8]}")

        if context_parts:
            record.msg = f"[{' '.join(context_parts)}] {record.msg}"

        return super().format(record)


def setup_logging(
    log_level: str = "INFO",
    log_file: Optional[str] = None,
    json_logs: bool = False,
) -> None:
    """
    Configure application logging.

    Args:
        log_level: Minimum log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        log_file: Optional file path for file logging
        json_logs: Use JSON format (True for production, False for development)
    """
    # Create logs directory if file logging is enabled
    if log_file:
        log_path = Path(log_file)
        log_path.parent.mkdir(parents=True, exist_ok=True)

    # Get root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, log_level.upper()))

    # Remove existing handlers
    root_logger.handlers.clear()

    # Create context filter
    context_filter = ContextFilter()

    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.DEBUG)
    console_handler.addFilter(context_filter)

    if json_logs:
        # JSON formatter for production
        json_formatter = CustomJsonFormatter(
            "%(timestamp)s %(level)s %(name)s %(message)s"
        )
        console_handler.setFormatter(json_formatter)
    else:
        # Colored formatter for development
        colored_formatter = ColoredFormatter(
            fmt="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
        console_handler.setFormatter(colored_formatter)

    root_logger.addHandler(console_handler)

    # File handler (optional)
    if log_file:
        file_handler = logging.FileHandler(log_file, encoding="utf-8")
        file_handler.setLevel(logging.DEBUG)
        file_handler.addFilter(context_filter)

        # Always use JSON format for file logs
        json_formatter = CustomJsonFormatter(
            "%(timestamp)s %(level)s %(name)s %(message)s"
        )
        file_handler.setFormatter(json_formatter)

        root_logger.addHandler(file_handler)

    # Set specific log levels for noisy libraries
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("asyncpg").setLevel(logging.WARNING)
    logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)

    # Log startup message
    logger = logging.getLogger(__name__)
    logger.info(
        f"Logging configured: level={log_level}, json={json_logs}, file={log_file}"
    )


def get_logger(name: str) -> logging.Logger:
    """
    Get a logger instance for a module.

    Args:
        name: Logger name (typically __name__ of the module)

    Returns:
        Configured logger instance
    """
    return logging.getLogger(name)
