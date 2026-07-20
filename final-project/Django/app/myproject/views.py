"""Прості view для перевірки роботи застосунку та підключення до PostgreSQL."""
from django.db import connection
from django.http import HttpResponse


def home(request):
    """Головна сторінка: показує статус підключення до бази даних."""
    try:
        connection.ensure_connection()
        db_status = "OK — підключення до PostgreSQL працює"
    except Exception as exc:  # noqa: BLE001
        db_status = f"ERROR: {exc}"

    html = f"""
    <html lang="uk">
      <head><meta charset="utf-8"><title>Django + PostgreSQL + Nginx</title></head>
      <body style="font-family: sans-serif; max-width: 640px; margin: 60px auto;">
        <h1>🚀 Django + PostgreSQL + Nginx</h1>
        <p>Застосунок працює та доступний через Nginx-проксі.</p>
        <p><strong>База даних:</strong> {db_status}</p>
      </body>
    </html>
    """
    return HttpResponse(html)
