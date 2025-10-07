from sqlalchemy import Column, Integer, String, Sequence
from .db import Base

class User(Base):
    __tablename__ = "users"
    __table_args__ = {"schema": "auth"}  # auth schema use kar rhe hain

    id = Column(Integer, Sequence("user_id_seq"), primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(200), nullable=False)
