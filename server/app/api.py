from app.modules.auth import auth_route
from fastapi import APIRouter
from app.modules.users import user_route
from app.routes import test_routes
from app.configs.app_config import app_config

api_router = APIRouter()

api_router.include_router(auth_route.router)
api_router.include_router(user_route.router)

# Include test routes in non-production environments
if app_config.ENVIRONMENT != "production":
    api_router.include_router(test_routes.router)

# api_router.include_router(file_route.router)
# api_router.include_router(gig_routes.router)
# api_router.include_router(chat_route.router)
# api_router.include_router(buddy_routes.router)
# api_router.include_router(review_routes.router)
# api_router.include_router(transaction_routes.router)
