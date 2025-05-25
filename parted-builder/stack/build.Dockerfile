FROM paketobuildpacks/builder-jammy-buildpackless-static
USER root
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

RUN mkdir -p /app/template
COPY server/CMakeLists.txt /app/template/
COPY server/main.cpp /app/template/
COPY server/part/part.hpp /app/template/part/

# Создание пользователя и группы cnb с UID и GID 1000
ARG CNB_USER_ID=1000
ARG CNB_GROUP_ID=1000

# Установка переменных окружения, необходимых для CNB
ENV CNB_USER_ID=${CNB_USER_ID}
ENV CNB_GROUP_ID=${CNB_GROUP_ID}

# Установка пользователя по умолчанию
USER ${CNB_USER_ID}:${CNB_GROUP_ID}

# Добавление метаданных стека
LABEL io.buildpacks.stack.id="sav9a.cpp.stack"
LABEL io.buildpacks.base.distro.name="ubuntu"
LABEL io.buildpacks.base.distro.version="22.04"
