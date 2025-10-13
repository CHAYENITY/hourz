"""
Test routes for exception handling demonstration.

These routes are for testing/development only and should be removed in production.
"""

from fastapi import APIRouter, HTTPException

from app.exceptions import (
    NotFoundException,
    UnauthorizedException,
    ForbiddenException,
    ValidationException,
    ConflictException,
    DatabaseException,
    BadRequestException,
)

router = APIRouter(prefix="/test", tags=["Testing"])


@router.get("/exception/not-found")
async def test_not_found():
    """Test NotFoundException"""
    raise NotFoundException(
        message="User with ID '12345' not found",
        details={"user_id": "12345", "suggestion": "Check the user ID and try again"},
    )


@router.get("/exception/unauthorized")
async def test_unauthorized():
    """Test UnauthorizedException"""
    raise UnauthorizedException(
        message="Invalid credentials provided",
        details={"reason": "Invalid email or password"},
    )


@router.get("/exception/forbidden")
async def test_forbidden():
    """Test ForbiddenException"""
    raise ForbiddenException(
        message="You don't have permission to access this resource",
        details={"required_role": "ADMIN", "current_role": "USER"},
    )


@router.get("/exception/validation")
async def test_validation():
    """Test ValidationException"""
    raise ValidationException(
        message="Invalid input data",
        details={
            "errors": [
                {"field": "email", "message": "Invalid email format"},
                {"field": "password", "message": "Password must be at least 8 characters"},
            ]
        },
    )


@router.get("/exception/conflict")
async def test_conflict():
    """Test ConflictException"""
    raise ConflictException(
        message="Email already registered",
        details={"email": "user@example.com", "suggestion": "Use a different email or login"},
    )


@router.get("/exception/database")
async def test_database():
    """Test DatabaseException"""
    raise DatabaseException(
        message="Database connection failed",
        details={"database": "postgresql", "host": "localhost"},
    )


@router.get("/exception/bad-request")
async def test_bad_request():
    """Test BadRequestException"""
    raise BadRequestException(
        message="Invalid JSON in request body",
        details={"line": 5, "column": 12},
    )


@router.get("/exception/http")
async def test_http_exception():
    """Test standard HTTPException"""
    raise HTTPException(
        status_code=418,
        detail="I'm a teapot - cannot brew coffee",
    )


@router.get("/exception/unhandled")
async def test_unhandled():
    """Test unhandled exception"""
    # This will trigger the generic exception handler
    raise ValueError("Something went terribly wrong!")


@router.get("/exception/division-by-zero")
async def test_division_by_zero():
    """Test unhandled exception (division by zero)"""
    result = 1 / 0
    return {"result": result}
