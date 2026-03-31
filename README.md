# DevOps

Навчальний репозиторій з DevOps-практиками.

## Проєкти

- [`DockerProject/`](./DockerProject) — Dockerized Django + PostgreSQL + Nginx

---

## DockerProject

Мінімальний Django-проєкт, розгорнутий у Docker Compose з трьома сервісами:

| Сервіс | Образ | Призначення |
|--------|-------|-------------|
| `web`  | Python 3.11 + Django | Django-застосунок |
| `db`   | PostgreSQL 15 | База даних |
| `nginx`| Nginx | Reverse proxy (порт 80) |

### Структура

```
DockerProject/
├── docker-compose.yml
├── .env                  # змінні середовища (не в git)
├── .env.example          # шаблон змінних
├── web/
│   ├── Dockerfile
│   ├── manage.py
│   ├── requirements.txt
│   └── myproject/
│       ├── settings.py
│       ├── urls.py
│       └── wsgi.py
└── nginx/
    └── nginx.conf
```

### Як запустити

**1. Перейди в директорію проєкту:**

```bash
cd DockerProject
```

**2. Скопіюй файл змінних середовища та за потреби відредагуй:**

```bash
cp .env.example .env
```

**3. Запусти контейнери:**

```bash
docker compose up --build
```

**4. У новому терміналі виконай міграції:**

```bash
docker compose exec web python manage.py migrate
```

**5. (Опційно) Створи суперкористувача для адмін-панелі:**

```bash
docker compose exec web python manage.py createsuperuser
```

### Доступ

| URL | Опис |
|-----|------|
| `http://localhost/` | Django через Nginx |
| `http://localhost/admin/` | Адмін-панель Django |
| `http://localhost:8000/` | Django напряму (без Nginx) |

### Зупинити

```bash
docker compose down
```

Щоб також видалити дані бази даних:

```bash
docker compose down -v
```
