# Use an image with poetry installed
FROM python:3.12

# Install poetry
RUN pip install poetry

# Set the working directory inside the container
WORKDIR /app

# Copy the entire project to the container
COPY . .

# Specify the Python version supported by your project in pyproject.toml
RUN poetry env use 3.12

# Install project dependencies
RUN poetry install

# Navigate to the backend directory
WORKDIR /app/backend

# Install Django
RUN poetry run pip install django

# Run database migrations
RUN poetry run python manage.py migrate

# Specify the command to run the local server
CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]

