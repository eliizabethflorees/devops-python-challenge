FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app

RUN groupadd -r devopsgroup && useradd -r -g devopsgroup devopsuser

COPY --from=builder /root/.local /home/devopsuser/.local
COPY . .

RUN chown -R devopsuser:devopsgroup /app
USER devopsuser

ENV PATH=/home/devopsuser/.local/bin:$PATH
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/').getcode()" || exit 1

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]