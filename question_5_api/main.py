from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def my_function():
    return {"message": "Hello, World!"}
