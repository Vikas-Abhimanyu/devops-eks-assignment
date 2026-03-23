from flask import Flask, jsonify
import psycopg2
import os

app = Flask(__name__)

# Function to connect to RDS PostgreSQL
def get_db_connection():
    conn = psycopg2.connect(
        host=os.environ.get("DB_HOST"),        # Terraform output: rds_endpoint
        database=os.environ.get("DB_NAME"),    # Terraform output: database_name
        user=os.environ.get("DB_USERNAME"),    # Secrets Manager: db_username
        password=os.environ.get("DB_PASSWORD"),# Secrets Manager: db_password
        port=os.environ.get("DB_PORT", "5432") # Terraform output: rds_port
    )
    return conn

@app.route("/")
def home():
    return {"message": "Backend API running"}

@app.route("/users")
def users():
    conn = get_db_connection()
    cur = conn.cursor()

    # Ensure table exists
    cur.execute("CREATE TABLE IF NOT EXISTS users(id SERIAL PRIMARY KEY, name TEXT);")
    cur.execute("INSERT INTO users(name) VALUES('DevOps User') RETURNING id;")

    user_id = cur.fetchone()[0]

    conn.commit()
    cur.close()
    conn.close()

    return jsonify({"created_user_id": user_id})

@app.route("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

