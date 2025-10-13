# 🧪 Exception Handler Testing Guide for Postman

## 📋 Setup

Make sure your server is running:
```bash
cd server
poetry run fastapi dev
```

Server should be at: `http://localhost:8000`

---

## 🎯 Test Cases

### **Test 1: Not Found Exception (404)**

**Request:**
- **Method:** `GET`
- **URL:** `http://localhost:8000/api/test/exception/not-found`

**Expected Response:**
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "User with ID '12345' not found",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": {
      "user_id": "12345",
      "suggestion": "Check the user ID and try again"
    }
  }
}
```

**Status Code:** `404`

**Check Server Logs For:**
```
2025-10-13 XX:XX:XX | ERROR | app.middleware.exception_handler | [req=...] Application error: NOT_FOUND - User with ID '12345' not found
```

---

### **Test 2: Unauthorized Exception (401)**

**Request:**
- **Method:** `GET`
- **URL:** `http://localhost:8000/api/test/exception/unauthorized`

**Expected Response:**
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid credentials provided",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": {
      "reason": "Invalid email or password"
    }
  }
}
```

**Status Code:** `401`

---

### **Test 3: Forbidden Exception (403)**

**Request:**
- **Method:** `GET`
- **URL:** `http://localhost:8000/api/test/exception/forbidden`

**Expected Response:**
```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "You don't have permission to access this resource",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": {
      "required_role": "ADMIN",
      "current_role": "USER"
    }
  }
}
```

**Status Code:** `403`

---

### **Test 4: Validation Exception (422)**

**Request:**
- **Method:** `GET`
- **URL:** `http://localhost:8000/api/test/exception/validation`

**Expected Response:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": {
      "errors": [
        {
          "field": "email",
          "message": "Invalid email format"
        },
        {
          "field": "password",
          "message": "Password must be at least 8 characters"
        }
      ]
    }
  }
}
```

**Status Code:** `422`

---

### **Test 5: Conflict Exception (409)**

**Request:**
- **Method:** `GET`
- **URL:** `http://localhost:8000/api/test/exception/conflict`

**Expected Response:**
```json
{
  "error": {
    "code": "CONFLICT",
    "message": "Email already registered",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": {
      "email": "user@example.com",
      "suggestion": "Use a different email or login"
    }
  }
}
```

**Status Code:** `409`

---

### **Test 6: Database Exception (500)**

**Request:**
- **Method:** `GET`
- **URL:** `http://localhost:8000/api/test/exception/database`

**Expected Response:**
```json
{
  "error": {
    "code": "DATABASE_ERROR",
    "message": "Database error: DatabaseException",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": {
      "message": "Database connection failed"
    }
  }
}
```

**Status Code:** `500`

---

### **Test 7: Bad Request Exception (400)**

**Request:**
- **Method:** `GET`
- **URL:** `http://localhost:8000/api/test/exception/bad-request`

**Expected Response:**
```json
{
  "error": {
    "code": "BAD_REQUEST",
    "message": "Invalid JSON in request body",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": {
      "line": 5,
      "column": 12
    }
  }
}
```

**Status Code:** `400`

---

### **Test 8: HTTP Exception (418)**

**Request:**
- **Method:** `GET`
- **URL:** `http://localhost:8000/api/test/exception/http`

**Expected Response:**
```json
{
  "error": {
    "code": "HTTP_ERROR",
    "message": "I'm a teapot - cannot brew coffee",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": null
  }
}
```

**Status Code:** `418`

---

### **Test 9: Unhandled Exception (500)**

**Request:**
- **Method:** `GET`
- **URL:** `http://localhost:8000/api/test/exception/unhandled`

**Expected Response:**
```json
{
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "Internal server error: ValueError",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": {
      "message": "Something went terribly wrong!",
      "type": "ValueError"
    }
  }
}
```

**Status Code:** `500`

**Check Server Logs For:**
```
2025-10-13 XX:XX:XX | ERROR | app.middleware.exception_handler | [req=...] Unhandled exception: ValueError - Something went terribly wrong!
```

---

### **Test 10: Division by Zero (500)**

**Request:**
- **Method:** `GET`
- **URL:** `http://localhost:8000/api/test/exception/division-by-zero`

**Expected Response:**
```json
{
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "Internal server error: ZeroDivisionError",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": {
      "message": "division by zero",
      "type": "ZeroDivisionError"
    }
  }
}
```

**Status Code:** `500`

---

### **Test 11: Real Pydantic Validation Error**

**Request:**
- **Method:** `POST`
- **URL:** `http://localhost:8000/api/auth/register`
- **Headers:** `Content-Type: application/json`
- **Body:** 
```json
{
  "email": "invalid-email",
  "password": "short"
}
```

**Expected Response:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "request_id": "...",
    "timestamp": "2025-10-13T...",
    "details": {
      "errors": [
        {
          "field": "body.phone_number",
          "message": "field required",
          "type": "value_error.missing"
        },
        {
          "field": "body.first_name",
          "message": "field required",
          "type": "value_error.missing"
        },
        ...
      ]
    }
  }
}
```

**Status Code:** `422`

---

## ✅ Verification Checklist

For each test, verify:

- [ ] **Status Code** matches expected (404, 401, 403, 422, 409, 400, 500, etc.)
- [ ] **Response Format** matches standardized error format
- [ ] **Error Code** is present and correct (NOT_FOUND, UNAUTHORIZED, etc.)
- [ ] **Request ID** is present in response (UUID format)
- [ ] **Timestamp** is present (ISO 8601 format)
- [ ] **X-Request-ID Header** is present in response headers
- [ ] **Server Logs** show the error with context
- [ ] **Server Logs** include request ID matching response

---

## 🔍 What to Look For

### **In Response:**
- Consistent JSON structure
- Clear error codes
- Human-readable messages
- Request ID for tracing
- Timestamp in UTC
- Optional details (dev mode)

### **In Server Logs:**
- Colored log output (ERROR in red, WARNING in yellow)
- Request ID context `[req=...]`
- Full error message
- Stack traces (for unhandled exceptions)
- Request path and method

### **In Response Headers:**
- `X-Request-ID: <uuid>`
- `Content-Type: application/json`

---

## 🎯 Success Criteria

✅ All 11 tests return expected error format  
✅ Status codes match expectations  
✅ Request IDs link responses to logs  
✅ Server logs show full error context  
✅ No server crashes or restarts  
✅ Consistent error format across all error types

---

## 📝 Postman Collection Snippet

You can import this into Postman:

```json
{
  "info": {
    "name": "Exception Handler Tests",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Test Not Found (404)",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/api/test/exception/not-found",
          "host": ["{{base_url}}"],
          "path": ["api", "test", "exception", "not-found"]
        }
      }
    },
    {
      "name": "Test Unauthorized (401)",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/api/test/exception/unauthorized",
          "host": ["{{base_url}}"],
          "path": ["api", "test", "exception", "unauthorized"]
        }
      }
    },
    {
      "name": "Test Forbidden (403)",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/api/test/exception/forbidden",
          "host": ["{{base_url}}"],
          "path": ["api", "test", "exception", "forbidden"]
        }
      }
    },
    {
      "name": "Test Validation (422)",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/api/test/exception/validation",
          "host": ["{{base_url}}"],
          "path": ["api", "test", "exception", "validation"]
        }
      }
    },
    {
      "name": "Test Unhandled (500)",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "{{base_url}}/api/test/exception/unhandled",
          "host": ["{{base_url}}"],
          "path": ["api", "test", "exception", "unhandled"]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:8000"
    }
  ]
}
```

---

**Ready to test!** Start making requests in Postman and watch both the responses and server logs. 🚀
