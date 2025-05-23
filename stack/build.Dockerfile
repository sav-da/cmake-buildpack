FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Установка необходимых пакетов для сборки C++ приложений
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    curl \
    ca-certificates \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Создание пользователя и группы cnb с UID и GID 1000
ARG CNB_USER_ID=1000
ARG CNB_GROUP_ID=1000

RUN groupadd --gid ${CNB_GROUP_ID} cnb && \
    useradd --uid ${CNB_USER_ID} --gid ${CNB_GROUP_ID} -m -s /bin/bash cnb
#RUN mkdir /layers && chmod -R 0777 /layers
# Установка переменных окружения, необходимых для CNB
ENV CNB_USER_ID=${CNB_USER_ID}
ENV CNB_GROUP_ID=${CNB_GROUP_ID}

# Установка пользователя по умолчанию
USER 1000:1000

# Добавление метаданных стека
LABEL io.buildpacks.stack.id="sav9a.cpp.stack"
LABEL io.buildpacks.base.distro.name="ubuntu"
LABEL io.buildpacks.base.distro.version="22.04"
