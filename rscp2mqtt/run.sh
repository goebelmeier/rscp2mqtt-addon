#!/usr/bin/with-contenv bashio

bashio::log.info "Preparing to start..."

# turn on bash's job control
set -m

bashio::log.info "Preparing env from add-on config"
RSCP2MQTT_E3DC_IP=$(bashio::config 'e3dc_ip')
RSCP2MQTT_E3DC_PORT=$(bashio::config 'e3dc_port')
RSCP2MQTT_E3DC_USER=$(bashio::config 'e3dc_user')
RSCP2MQTT_E3DC_PASSWORD=$(bashio::config 'e3dc_password')
RSCP2MQTT_E3DC_AES_PASSWORD=$(bashio::config 'e3dc_aes_password')
RSCP2MQTT_MQTT_HOST=$(bashio::services mqtt "host")
RSCP2MQTT_MQTT_PORT=$(bashio::services mqtt "port")
RSCP2MQTT_MQTT_USER=$(bashio::services mqtt "username")
RSCP2MQTT_MQTT_PASSWORD=$(bashio::services mqtt "password")
RSCP2MQTT_MQTT_QOS=$(bashio::config 'mqtt_qos')
RSCP2MQTT_MQTT_RETAIN=$(bashio::config 'mqtt_retain')
RSCP2MQTT_LOGFILE=$(bashio::config 'logfile')
RSCP2MQTT_INTERVAL=$(bashio::config 'interval')
RSCP2MQTT_PVI_REQUESTS=$(bashio::config 'pvi_requests')
RSCP2MQTT_PVI_TRACKER=$(bashio::config 'pvi_tracker')
RSCP2MQTT_PM_REQUESTS=$(bashio::config 'pm_requests')
RSCP2MQTT_AUTO_REFRESH=$(bashio::config 'auto_refresh')
RSCP2MQTT_DRYRUN=$(bashio::config 'dryrun')

bashio::log.info "Generating .config file"
cat << EOF > /opt/rscp2mqtt/.config
E3DC_IP=$RSCP2MQTT_E3DC_IP
E3DC_PORT=$RSCP2MQTT_E3DC_PORT
E3DC_USER=$RSCP2MQTT_E3DC_USER
E3DC_PASSWORD=$RSCP2MQTT_E3DC_PASSWORD
E3DC_AES_PASSWORD=$RSCP2MQTT_E3DC_AES_PASSWORD
MQTT_HOST=$RSCP2MQTT_MQTT_HOST
MQTT_PORT=$RSCP2MQTT_MQTT_PORT
MQTT_AUTH=true
MQTT_USER=$RSCP2MQTT_MQTT_USER
MQTT_PASSWORD=$RSCP2MQTT_MQTT_PASSWORD
MQTT_QOS=$RSCP2MQTT_MQTT_QOS
MQTT_RETAIN=$RSCP2MQTT_MQTT_RETAIN
LOGFILE=$RSCP2MQTT_LOGFILE
INTERVAL=$RSCP2MQTT_INTERVAL
PVI_REQUESTS=$RSCP2MQTT_PVI_REQUESTS
PVI_TRACKER=$RSCP2MQTT_PVI_TRACKER
PM_REQUESTS=$RSCP2MQTT_PM_REQUESTS
AUTO_REFRESH=$RSCP2MQTT_AUTO_REFRESH
DRYRUN=$RSCP2MQTT_DRYRUN
EOF

bashio::log.info "Starting rscp2mqtt"
cd /opt/rscp2mqtt/ || exit
# Start the primary process and put it in the background
/opt/rscp2mqtt/rscp2mqtt &

bashio::log.info "Creating MQTT Discovery"

sleep 5
bashio::log.info "Fetching device information"
MQTT_SUB="/usr/bin/mosquitto_sub -h $(bashio::services mqtt "host") -p $(bashio::services mqtt "port") -u $(bashio::services mqtt "username") -P $(bashio::services mqtt "password") -C 1"
SERIAL=$($MQTT_SUB -t e3dc/system/serial_number)
SOFTWARE=$($MQTT_SUB -t e3dc/system/software)

sleep 5
bashio::log.info "Publishing entities"
DEVICE='"device": {"ids": ["'${SERIAL}'"], "name": "E3/DC S10", "mdl": "S10", "mf": "E3/DC", "sw": "'${SOFTWARE}'"}'
MQTT_PUB="/usr/bin/mosquitto_pub -r -h $(bashio::services mqtt "host") -p $(bashio::services mqtt "port") -u $(bashio::services mqtt "username") -P $(bashio::services mqtt "password")"

UNIQUE_PREFIX=e3dc-${SERIAL}

UNIQUE_ID=${UNIQUE_PREFIX}-addon-power
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Addon Power", "stat_t": "e3dc/addon/power", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:meter-electric", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-autarky
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Autarky", "stat_t": "e3dc/autarky", "stat_cla": "measurement", "unit_of_meas": "%", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-currentrscp2mqtt/run.sh
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Current", "stat_t": "e3dc/battery/current", "unit_of_meas": "A", "dev_cla": "current", "stat_cla": "measurement", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-cycles
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Cycles", "stat_t": "e3dc/battery/cycles", "stat_cla": "total_increasing", "ic": "mdi:autorenew", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-dcb_count
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Modules Count", "stat_t": "e3dc/battery/dcb_count", "stat_cla": "measurement", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-energy-charge
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Energy Charge", "stat_t": "e3dc/battery/energy/charge", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-energy-discharge
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Energy Discharge", "stat_t": "e3dc/battery/energy/discharge", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-error
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Error Code", "stat_t": "e3dc/battery/error", "ic": "mdi:alert", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-name
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Device Name", "stat_t": "e3dc/battery/name", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-power
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Power", "stat_t": "e3dc/battery/power", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-rsoc
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery RSoC", "stat_t": "e3dc/battery/rsoc", "unit_of_meas": "%", "dev_cla": "battery", "stat_cla": "measurement", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-soc
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery SoC", "stat_t": "e3dc/battery/soc", "unit_of_meas": "%", "dev_cla": "battery", "stat_cla": "measurement", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-status
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Status Code", "stat_t": "e3dc/battery/status", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-training
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Training Mode", "stat_t": "e3dc/battery/training", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-battery-voltage
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Battery Voltage", "stat_t": "e3dc/battery/voltage", "unit_of_meas": "V", "dev_cla": "voltage", "stat_cla": "measurement", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-consumed
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Consumed Production", "stat_t": "e3dc/consumed", "unit_of_meas": "%", "stat_cla": "measurement", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-coupling-mode
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Coupling Mode", "stat_t": "e3dc/coupling/mode", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-discharge_start-power
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Discharge Start Power", "stat_t": "e3dc/ems/discharge_start/power", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-grid-energy-in
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Grid In Energy", "stat_t": "e3dc/grid/energy/in", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:transmission-tower-export", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-grid-energy-out
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Grid Out Energy", "stat_t": "e3dc/grid/energy/out", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:transmission-tower-import", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-grid-power
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Grid Power", "stat_t": "e3dc/grid/power", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-home-energy
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Home Energy", "stat_t": "e3dc/home/energy", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:home", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-home-power
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Home Power", "stat_t": "e3dc/home/power", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:home", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-mode
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Mode", "stat_t": "e3dc/mode", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-month-autarky
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Month Autarky", "stat_t": "e3dc/month/autarky", "unit_of_meas": "%", "stat_cla": "measurement", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-month-battery-energy-charge
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Month Battery Energy Charge", "stat_t": "e3dc/month/battery/energy/charge", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-month-battery-energy-discharge
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Month Battery Energy Discharge", "stat_t": "e3dc/month/battery/energy/discharge", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-month-consumed
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Month Consumed Production", "stat_t": "e3dc/month/consumed", "unit_of_meas": "%", "stat_cla": "measurement", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-month-grid-energy-in
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Month Grid In Energy", "stat_t": "e3dc/month/grid/energy/in", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:transmission-tower-export", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-month-grid-energy-out
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Month Grid Out Energy", "stat_t": "e3dc/month/grid/energy/out", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:transmission-tower-import", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-month-home-energy
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Month Home Energy", "stat_t": "e3dc/month/home/energy", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:home", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-month-solar-energy
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Month Solar Energy", "stat_t": "e3dc/month/solar/energy", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-energy-l1
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Energy L1", "stat_t": "e3dc/pm/energy/L1", "unit_of_meas": "Wh", "dev_cla": "energy", "stat_cla": "total", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-energy-l2
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Energy L2", "stat_t": "e3dc/pm/energy/L2", "unit_of_meas": "Wh", "dev_cla": "energy", "stat_cla": "total", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-energy-l3
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Energy L3", "stat_t": "e3dc/pm/energy/L3", "unit_of_meas": "Wh", "dev_cla": "energy", "stat_cla": "total", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-power-l1
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Power L1", "stat_t": "e3dc/pm/power/L1", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-power-l2
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Power L2", "stat_t": "e3dc/pm/power/L2", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-power-l3
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Power L3", "stat_t": "e3dc/pm/power/L3", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-voltage-l1
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Voltage L1", "stat_t": "e3dc/pm/voltage/L1", "unit_of_meas": "V", "dev_cla": "voltage", "stat_cla": "measurement", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-voltage-l2
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Voltage L2", "stat_t": "e3dc/pm/voltage/L2", "unit_of_meas": "V", "dev_cla": "voltage", "stat_cla": "measurement", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-voltage-l3
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Voltage L3", "stat_t": "e3dc/pm/voltage/L3", "unit_of_meas": "V", "dev_cla": "voltage", "ic": "mdi:lightning-bolt", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-current-l1
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Current L1", "stat_t": "e3dc/pvi/current/L1", "unit_of_meas": "A", "dev_cla": "current", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-current-l2
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Current L2", "stat_t": "e3dc/pvi/current/L2", "unit_of_meas": "A", "dev_cla": "current", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-current-l3
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Current L3", "stat_t": "e3dc/pvi/current/L3", "unit_of_meas": "A", "dev_cla": "current", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-current-string1
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Current String 1", "stat_t": "e3dc/pvi/current/string_1", "unit_of_meas": "A", "dev_cla": "current", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-current-string2
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Current String 1", "stat_t": "e3dc/pvi/current/string_2", "unit_of_meas": "A", "dev_cla": "current", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-power-l1
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Power L1", "stat_t": "e3dc/pvi/power/L1", "unit_of_meas": "W", "dev_cla": "power", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-power-l2
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Power L2", "stat_t": "e3dc/pvi/power/L2", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-power-l3
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Power L3", "stat_t": "e3dc/pvi/power/L3", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-power-string1
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Power String 1", "stat_t": "e3dc/pvi/power/string_1", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-power-string2
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Power String 1", "stat_t": "e3dc/pvi/power/string_2", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-voltage-l1
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Voltage L1", "stat_t": "e3dc/pvi/voltage/L1", "unit_of_meas": "V", "dev_cla": "voltage", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-voltage-l2
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Voltage L2", "stat_t": "e3dc/pvi/voltage/L2", "unit_of_meas": "V", "dev_cla": "voltage", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-voltage-l3
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Voltage L3", "stat_t": "e3dc/pvi/voltage/L3", "unit_of_meas": "V", "dev_cla": "voltage", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-voltage-string1
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Voltage String 1", "stat_t": "e3dc/pvi/voltage/string_1", "unit_of_meas": "V", "dev_cla": "voltage", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-voltage-string2
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI Voltage String 2", "stat_t": "e3dc/pvi/voltage/string_2", "unit_of_meas": "V", "dev_cla": "voltage", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-reserve-last_soc
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC EP Reserve Last SoC", "stat_t": "e3dc/reserve/last_soc", "unit_of_meas": "%", "dev_cla": "battery", "stat_cla": "measurement", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-reserve-max
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC EP Reserve Max Energy", "stat_t": "e3dc/reserve/max", "unit_of_meas": "Wh", "dev_cla": "energy", "stat_cla": "total", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-solar-energy
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Solar Energy", "stat_t": "e3dc/solar/energy", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-solar-power
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Solar Power", "stat_t": "e3dc/solar/power", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-system-derate_at_percent_value
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Derate at percent value", "stat_t": "e3dc/system/derate_at_percent_value", "unit_of_meas": "%", "stat_cla": "measurement", "ic": "mdi:lock", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-system-derate_at_power_value
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Derate at power value", "stat_t": "e3dc/system/derate_at_power_value", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:lock", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-system-installed_peak_power
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Installed Peak Power", "stat_t": "e3dc/system/installed_peak_power", "unit_of_meas": "W", "dev_cla": "power", "stat_cla": "measurement", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-system-production_date
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Production Date", "stat_t": "e3dc/system/production_date", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-system-serial_number
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Serial Number", "stat_t": "e3dc/system/serial_number", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-system-software
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Software Release", "stat_t": "e3dc/system/software", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-time-zone
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Time Zone", "stat_t": "e3dc/time/zone", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-week-autarky
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Week Autarky", "stat_t": "e3dc/week/autarky", "unit_of_meas": "%", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-week-battery-energy-charge
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Week Battery Energy Charge", "stat_t": "e3dc/week/battery/energy/charge", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-week-battery-energy-discharge
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Week Battery Energy Discharge", "stat_t": "e3dc/week/battery/energy/discharge", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-week-consumed
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Week Consumed Production", "stat_t": "e3dc/week/consumed", "unit_of_meas": "%", "stat_cla": "measurement", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-week-grid-energy-in
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Week Grid In Energy", "stat_t": "e3dc/week/grid/energy/in", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:transmission-tower-import", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-week-grid-energy-out
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Week Grid Out Energy", "stat_t": "e3dc/week/grid/energy/out", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:transmission-tower-export", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-week-home-energy
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Week Home Energy", "stat_t": "e3dc/week/home/energy", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:home", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-week-solar-energy
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Week Solar Energy", "stat_t": "e3dc/week/solar/energy", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-year-autarky
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Year Autarky", "stat_t": "e3dc/year/autarky", "unit_of_meas": "%", "stat_cla": "measurement", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-year-battery-energy-charge
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Year Battery Charge Energy", "stat_t": "e3dc/year/battery/energy/charge", "unit_of_meas": "kWh", "dev_cla": "energy_storage", "stat_cla": "measurement", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-year-battery-energy-discharge
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Year Battery Discharge Energy", "stat_t": "e3dc/year/battery/energy/discharge", "unit_of_meas": "kWh", "dev_cla": "energy_storage", "stat_cla": "measurement", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-year-consumed
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Year Consumed Production", "stat_t": "e3dc/year/consumed", "unit_of_meas": "%", "stat_cla": "measurement", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-year-grid-energy-in
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Year Grid In Energy", "stat_t": "e3dc/year/grid/energy/in", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:transmission-tower-import", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-year-grid-energy-out
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Year Grid Out Energy", "stat_t": "e3dc/year/grid/energy/out", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:transmission-tower-export", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-year-home-energy
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Year Home Energy", "stat_t": "e3dc/year/home/energy", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:home", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-year-solar-energy
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Year Solar Energy", "stat_t": "e3dc/year/solar/energy", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:solar-power", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-yesterday-autarky
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Yesterday Autarky", "stat_t": "e3dc/yesterday/autarky", "unit_of_meas": "%", "stat_cla": "measurement", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-yesterday-battery-energy-charge
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Yesterday Battery Energy Charge", "stat_t": "e3dc/yesterday/battery/energy/charge", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-yesterday-battery-energy-discharge
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Yesterday Battery Energy Discharge", "stat_t": "e3dc/yesterday/battery/energy/discharge", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-yesterday-battery-soc
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Yesterday Battery SoC", "stat_t": "e3dc/yesterday/battery/soc", "unit_of_meas": "%", "dev_cla": "battery", "stat_cla": "measurement", "ic": "mdi:battery", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-yesterday-consumed
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Yesterday Consumed Production", "stat_t": "e3dc/yesterday/consumed", "unit_of_meas": "%", "stat_cla": "measurement", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-yesterday-grid-energy-in
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Yesterday Grid In Energy", "stat_t": "e3dc/yesterday/grid/energy/in", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:transmission-tower-import", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-yesterday-grid-energy-out
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Yesterday Grid Out Energy", "stat_t": "e3dc/yesterday/grid/energy/out", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:transmission-tower-export", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-yesterday-home-energy
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Yesterday Home Energy", "stat_t": "e3dc/yesterday/home/energy", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:home", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-yesterday-solar-energy
$MQTT_PUB -t homeassistant/sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Yesterday Solar Energy", "stat_t": "e3dc/yesterday/solar/energy", "unit_of_meas": "kWh", "dev_cla": "energy", "stat_cla": "total_increasing", "ic": "mdi:solar-power", '"${DEVICE}"'}'


UNIQUE_ID=${UNIQUE_PREFIX}-ems-balanced_phases-l1
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Balanced Phase L1", "stat_t": "e3dc/ems/balanced_phases/L1", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-balanced_phases-l2
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Balanced Phase L2", "stat_t": "e3dc/ems/balanced_phases/L2", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-balanced_phases-l3
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Balanced Phase L3", "stat_t": "e3dc/ems/balanced_phases/L3", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-charging_lock
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Charging Lock", "stat_t": "e3dc/ems/charging_lock", "pl_on": "true", "pl_off": "false", "ic": "mdi:lock", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-charging_throttled
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Charging Throttled", "stat_t": "e3dc/ems/charging_throttled", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-charging_time_lock
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Charging Time Lock", "stat_t": "e3dc/ems/charging_time_lock", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-discharging_lock
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Discharging Lock", "stat_t": "e3dc/ems/discharging_lock", "pl_on": "true", "pl_off": "false", "ic": "mdi:lock", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-discharging_time_lock
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Discharging Time Lock", "stat_t": "e3dc/ems/discharging_time_lock", "pl_on": "true", "pl_off": "false", "ic": "mdi:lock", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-emergency_power_available
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Emergency Power Available", "stat_t": "e3dc/ems/emergency_power_available", "pl_on": "true", "pl_off": "false", "ic": "mdi:shield-alert", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-power_save
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Powersave Enabled", "stat_t": "e3dc/ems/power_save", "pl_on": "true", "pl_off": "false", "ic": "mdi:power-standby", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-grid_in_limit
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Grid In Limit", "stat_t": "e3dc/grid_in_limit", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-active_phases-l1
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Active Phase L1", "stat_t": "e3dc/pm/active_phases/L1", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-active_phases-l2
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Active Phase L2", "stat_t": "e3dc/pm/active_phases/L2", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pm-active_phases-l3
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PM Active Phase L3", "stat_t": "e3dc/pm/active_phases/L3", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-pvi-on_grid
$MQTT_PUB -t homeassistant/binary_sensor/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC PVI On Grid", "stat_t": "e3dc/pvi/on_grid", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'


UNIQUE_ID=${UNIQUE_PREFIX}-ems-weather_regulation
$MQTT_PUB -t homeassistant/switch/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Weather Regulation Enable", "stat_t": "e3dc/ems/weather_regulation", "cmd_t": "e3dc/set/weather_regulation", "pl_on": "true", "pl_off": "false", "ic": "mdi:weather-cloudy-clock", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-power_limits
$MQTT_PUB -t homeassistant/switch/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Power Limits Used", "stat_t": "e3dc/ems/power_limits", "cmd_t": "e3dc/set/power_limits", "pl_on": "true", "pl_off": "false", '"${DEVICE}"'}'


UNIQUE_ID=${UNIQUE_PREFIX}-ems-max_charge-power
$MQTT_PUB -t homeassistant/number/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Max Charge Power", "stat_t": "e3dc/ems/max_charge/power", "cmd_t": "e3dc/set/max_charge_power", "unit_of_meas": "W", "dev_cla": "power", "ic": "mdi:lightning-bolt", "min": "0", "max": "3000", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-max_discharge-power
$MQTT_PUB -t homeassistant/number/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC Max Discharge Power", "stat_t": "e3dc/ems/max_discharge/power", "cmd_t": "e3dc/set/max_discharge_power", "unit_of_meas": "W", "dev_cla": "power", "ic": "mdi:lightning-bolt", "min": "0", "max": "3000", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-reserve-energy
$MQTT_PUB -t homeassistant/number/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC EP Reserve Energy", "stat_t": "e3dc/reserve/energy", "cmd_t": "e3dc/set/reserve/energy", "unit_of_meas": "Wh", "dev_cla": "energy", "ic": "mdi:battery", "min": "0", '"${DEVICE}"'}'

UNIQUE_ID=${UNIQUE_PREFIX}-ems-reserve-percent
$MQTT_PUB -t homeassistant/number/${UNIQUE_ID}/config -m '{"uniq_id": "'${UNIQUE_ID}'", "name": "E3DC EP Reserve", "stat_t": "e3dc/reserve/percent", "cmd_t": "e3dc/set/reserve/percent", "unit_of_meas": "%", "dev_cla": "battery", "ic": "mdi:battery", "min": "0", "max": "100", '"${DEVICE}"'}'

bashio::log.info "Finished publishing entities"

# now we bring the primary process back into the foreground
# and leave it there
fg %1