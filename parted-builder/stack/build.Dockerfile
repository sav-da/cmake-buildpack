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
    libgrpc-dev \
    libprotobuf-dev \
    libgrpc++-dev \
    protobuf-compiler-grpc \
    && rm -rf /var/lib/apt/lists/*


# Клонируем uWebSockets с подмодулями
RUN git clone --recursive https://github.com/uNetworking/uWebSockets.git /uWebSockets && \
    cd /uWebSockets && \
    git checkout v20.73.0

# Собираем uSockets (создает uSockets.a)
RUN cd /uWebSockets/uSockets && \
    make -j $(nproc) && cd ../ && make install

# Проверяем наличие библиотеки uSockets.a
RUN find /uWebSockets -name "uSockets.a" || echo "uSockets.a not found"

# Копируем статическую библиотеку и заголовки в системные директории
RUN cp /uWebSockets/uSockets/uSockets.a /usr/local/lib/libuWS.a && \
    mkdir -p /usr/local/include/uWebSockets && \
    cp /uWebSockets/src/*.h /usr/local/include/uWebSockets/ && \
    cp /uWebSockets/uSockets/src/*.h /usr/local/include/

# Проверяем содержимое для диагностики
RUN ls -l /usr/local/lib/libuWS.a || echo "libuWS.a not copied" && \
    ls -l /usr/local/include/uWebSockets/ || echo "uWebSockets headers not found" && \
    ls -l /usr/local/include/libusockets.h || echo "libusockets.h not found"

ENV GRPC_VERSION=1.66.0

RUN git clone --recurse-submodules -b v${GRPC_VERSION} --depth 1 --shallow-submodules https://github.com/grpc/grpc && \
    cd grpc && \
    cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -B build && \
    cmake --build build --parallel 4 && \
    cmake --build build --parallel --target install

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
