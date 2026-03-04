from fastapi import FastAPI
from pydantic import BaseModel
import psycopg2
import os

app = FastAPI()

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = "postgres"

class Score(BaseModel):
    username: str
    score: int

@app.post("/submit")
def submit_score(data: Score):
    conn = psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        dbname=DB_NAME
    )
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS scores (username TEXT, score INT);")
    cur.execute("INSERT INTO scores VALUES (%s, %s);", (data.username, data.score))
    conn.commit()
    cur.close()
    conn.close()
    return {"message": "Score submitted"}

@app.get("/leaderboard")
def leaderboard():
    conn = psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        dbname=DB_NAME
    )
    cur = conn.cursor()
    cur.execute("SELECT * FROM scores ORDER BY score DESC;")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return rows
