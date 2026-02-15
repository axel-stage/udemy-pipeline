ARG PYTHON_VERSION=3.13

FROM ghcr.io/astral-sh/uv:0.9.16 AS uv

FROM public.ecr.aws/lambda/python:${PYTHON_VERSION} AS builder

ENV UV_COMPILE_BYTECODE=1

ENV UV_NO_INSTALLER_METADATA=1

ENV UV_LINK_MODE=copy

RUN --mount=from=uv,source=/uv,target=/bin/uv \
    --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv export --frozen --no-emit-workspace --no-dev --no-editable -o requirements.txt && \
    uv pip install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

FROM public.ecr.aws/lambda/python:${PYTHON_VERSION}

ARG SRC_PATH \
    AUTHOR \
    DESCRIPTION

LABEL org.opencontainers.image.authors=${AUTHOR} \
    org.opencontainers.image.description=${DESCRIPTION}

COPY --from=builder ${LAMBDA_TASK_ROOT} ${LAMBDA_TASK_ROOT}

COPY ${SRC_PATH} ${LAMBDA_TASK_ROOT}

CMD ["main.lambda_handler"]
