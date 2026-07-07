FROM python:3.10-slim

WORKDIR /app

RUN pip install --no-cache-dir requests beautifulsoup4

COPY bot.py .

CMD ["python", "-u", "bot.py"]
