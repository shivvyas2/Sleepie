from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Supabase
    supabase_url: str
    supabase_anon_key: str
    supabase_jwt_secret: str = ""

    # HuggingFace
    huggingface_api_token: str = ""

    # CORS
    cors_origins: list[str] = ["*"]

    # App
    app_name: str = "Sleepie API"
    debug: bool = False

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
