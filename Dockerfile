FROM python:alpine
COPY bookstore-api.py requirements.txt ./app/
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 80
CMD ["python3", "bookstore-api.py"]