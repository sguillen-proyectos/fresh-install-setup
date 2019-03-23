FROM debian:stretch

RUN mkdir -p /app

WORKDIR /app
COPY . /app

CMD ["/bin/bash"]
