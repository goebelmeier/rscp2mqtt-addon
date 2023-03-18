ARG BUILD_FROM
FROM $BUILD_FROM as builder
RUN apk add --no-cache mosquitto-dev
RUN apk add --no-cache git
RUN apk add --no-cache build-base
WORKDIR /tmp
RUN git clone https://github.com/pvtom/rscp2mqtt.git
WORKDIR /tmp/rscp2mqtt
RUN mkdir -p /opt/rscp2mqtt/
RUN g++ -O0 RscpMqttMain.cpp RscpProtocol.cpp AES.cpp SocketConnection.cpp -pthread -lmosquitto -o /opt/rscp2mqtt/rscp2mqtt
COPY run.sh /
RUN chmod +x /run.sh
CMD [ "/run.sh" ]