import logging
from fastapi import FastAPI, status
from fastapi.routing import APIRoute
from fastapi.responses import JSONResponse
from fastapi.openapi.utils import get_openapi
from fastapi.exceptions import RequestValidationError
from starlette.middleware.cors import CORSMiddleware
from starlette.exceptions import HTTPException as StarletteHTTPException
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from contextlib import asynccontextmanager

from app.api import api_router
from app.configs.app_config import app_config
from app.database.session import engine
from app.middleware.request_id import RequestIdMiddleware
from app.middleware.logging_middleware import LoggingMiddleware
from app.middleware.exception_handler import (
    app_exception_handler,
    http_exception_handler,
    validation_exception_handler,
    sqlalchemy_exception_handler,
    generic_exception_handler,
)
from app.exceptions import AppException
from app.utils.logger import setup_logging, get_logger

# Setup structured logging
setup_logging(
    log_level="DEBUG" if app_config.ENVIRONMENT == "development" else "INFO",
    json_logs=app_config.ENVIRONMENT == "production",
    log_file="logs/app.log" if app_config.ENVIRONMENT == "production" else None,
)

logger = get_logger(__name__)


def custom_generate_unique_id(route: APIRoute) -> str:
    if route.tags:
        return f"{route.tags[0]}-{route.name}"
    return route.name


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        async with engine.begin() as conn:
            await conn.execute(text("SELECT 1"))
        logger.info("🚀 Connected to SQLite")
    except Exception as e:
        logger.error("❌ Failed to connect to SQLite: %s", e)
        raise e

    yield

    await engine.dispose()
    logger.info("🧹 Async engine disposed")


app = FastAPI(
    title=app_config.PROJECT_NAME,
    generate_unique_id_function=custom_generate_unique_id,
    lifespan=lifespan,
    docs_url="/docs" if app_config.ENVIRONMENT != "production" else None,
    redoc_url=None,
    openapi_url="/openapi.json" if app_config.ENVIRONMENT != "production" else None,
)

# Register exception handlers (order matters - most specific first)
app.add_exception_handler(AppException, app_exception_handler)
app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(SQLAlchemyError, sqlalchemy_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)

# Add middleware (order matters - first added is executed last)
# Request ID middleware - first to set context
app.add_middleware(RequestIdMiddleware)

# Logging middleware - logs requests with request ID
app.add_middleware(LoggingMiddleware)

if app_config.all_cors_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=app_config.all_cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(api_router, prefix=app_config.API_STR)


@app.get("/", tags=["Default"])
async def root():
    return {"message": "Welcome to HOURZ API"}


@app.get("/health", tags=["Monitoring"])
async def health_check():
    try:
        async with engine.begin() as conn:
            await conn.execute(text("SELECT 1"))
        return {"status": "ok"}
    except Exception:
        return JSONResponse(
            content={"status": "unhealthy"},
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        )


def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title=app.title,
        version="1.0.0",
        description="API for HOURZ",
        routes=app.routes,
    )

    openapi_schema["components"]["securitySchemes"] = {
        "RefreshToken": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "Use refresh token",
        },
        "AccessToken": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "Use access token",
        },
    }

    protected_access_token_paths = [
        f"{app_config.API_STR}/users/me",
    ]

    protected_refresh_token_paths = [
        f"{app_config.API_STR}/auth/refresh",
    ]

    for path, methods in openapi_schema["paths"].items():
        for method in methods.values():
            if any(path.startswith(p) for p in protected_access_token_paths):
                method["security"] = [{"AccessToken": []}]
            elif any(path.startswith(p) for p in protected_refresh_token_paths):
                method["security"] = [{"RefreshToken": []}]

    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi
