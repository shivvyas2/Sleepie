from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query

from app.analytics.schemas import SleepSummary, TrendData
from app.analytics.service import AnalyticsService
from app.dependencies import get_current_user, get_supabase_client

router = APIRouter()


def get_analytics_service(supabase=Depends(get_supabase_client)) -> AnalyticsService:
    return AnalyticsService(supabase)


@router.get("/summary", response_model=SleepSummary)
async def get_summary(
    user_id: UUID = Depends(get_current_user),
    service: AnalyticsService = Depends(get_analytics_service),
):
    return await service.get_summary(user_id)


@router.get("/trends", response_model=TrendData)
async def get_trends(
    days: int = Query(default=30, ge=1, le=365),
    user_id: UUID = Depends(get_current_user),
    service: AnalyticsService = Depends(get_analytics_service),
):
    try:
        return await service.get_trends(user_id, days)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
