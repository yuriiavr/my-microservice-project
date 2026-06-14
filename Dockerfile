# Образ Python 3.9+ (використовуємо 3.11 — стабільний та підтримуваний).
FROM python:3.11-slim

# Налаштування середовища Python.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Системні залежності для psycopg2 (на випадок збірки з джерел).
RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Встановлюємо Python-залежності з requirements.txt.
COPY requirements.txt /app/
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Копіюємо код проєкту.
COPY . /app/

EXPOSE 8000

# Запуск Django-сервера в контейнері.
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
