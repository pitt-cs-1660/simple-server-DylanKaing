FROM python:3.12 AS builder

RUN pip install uv

WORKDIR /app

COPY pyproject.toml ./

RUN uv venv /opt/venv && \
    . /opt/venv/bin/activate && \
    uv pip install -r pyproject.toml

FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv

COPY cc_simple_server ./cc_simple_server
COPY tests ./tests

RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 8000

ENV PYTHONPATH=/app
CMD ["/opt/venv/bin/uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]