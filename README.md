# Мій власний мікросервісний проєкт
Це репозиторій для навчального проєкту в межах курсу "DevOps CI/CD".

## Мета
Навчитися основам роботи з Git і GitHub.

## Lesson 4 — Dockerized Django + PostgreSQL + Nginx

Контейнеризований вебзастосунок із трьох сервісів:

- **web** — Django-застосунок (Python 3.11);
- **db** — PostgreSQL 15 для збереження даних;
- **nginx** — проксі-сервер, що приймає запити на порту 80 і передає їх на Django.

### Структура

```
.
├── Dockerfile            # образ Django-застосунку
├── docker-compose.yml    # опис сервісів web / db / nginx
├── requirements.txt      # Python-залежності
├── .env                  # змінні оточення (dev-значення)
├── manage.py
├── myproject/            # Django-проєкт
│   ├── settings.py       # БД та конфіг із змінних оточення
│   ├── urls.py
│   ├── views.py
│   ├── wsgi.py / asgi.py
└── nginx/
    └── nginx.conf        # проксирування на http://django:8000
```

### Запуск

```bash
docker-compose up -d --build
```

Після старту:

- вебзастосунок доступний на http://localhost (через Nginx);
- головна сторінка показує статус підключення до PostgreSQL.

Зупинка:

```bash
docker-compose down        # зупинити
docker-compose down -v     # зупинити та видалити дані БД
```
