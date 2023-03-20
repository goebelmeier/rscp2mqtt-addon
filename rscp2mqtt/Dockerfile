ARG BUILD_FROM
FROM $BUILD_FROM as builder
RUN apk add --no-cache mosquitto-dev@2.0.15-r1
RUN apk add --no-cache git@2.38.4-r1
RUN apk add --no-cache build-base@0.5-r3
WORKDIR /tmp
RUN git clone https://github.com/pvtom/rscp2mqtt.git
WORKDIR /tmp/rscp2mqtt
RUN mkdir -p /opt/rscp2mqtt/
RUN g++ -O0 RscpMqttMain.cpp RscpProtocol.cpp AES.cpp SocketConnection.cpp -pthread -lmosquitto -o /opt/rscp2mqtt/rscp2mqtt
COPY run.sh /
RUN chmod +x /run.sh
CMD [ "/run.sh" ]