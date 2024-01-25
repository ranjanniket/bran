FROM python:3.12
RUN pip install poetry

WORKDIR /app
COPY . .

RUN poetry env use 3.12
RUN poetry install

WORKDIR /app/backend
RUN poetry run pip install django

RUN poetry run python manage.py migrate
CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]

