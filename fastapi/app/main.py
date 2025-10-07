from fastapi import FastAPI
from . import auth

app = FastAPI(title="Email Campaign API")

# include auth router
app.include_router(auth.router)

@app.get("/")
def root():
    return {"message": "FastAPI + Listmonk Integration running 🚀"}
