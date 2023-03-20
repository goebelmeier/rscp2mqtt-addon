# Home Assistant rscp2mqtt Add-on: Bridge between an E3/DC pv inverter device and a MQTT broker

This is an add-on for Home Assistant which uses the Remote-Storage-Control-Protocol (RSCP) to communicate with E3/DC
home power plants consisting of PV inverters, batteries and battery converters. This addon is based on the great
[rscp2mqtt][rscp2mqtt] projekt which itself is based on the HagerEnergy RSCP sample application.

The tool fetches the data cyclically from the S10 and publishes it to the MQTT broker under certain topics. Only
modified values will be published.

Supported topic areas are:

- Energy topics for today
- Current power values
- Autarky and self-consumption
- Battery status
- Energy management (EMS) power settings
- Data from yesterday and the current week, month and year
- Values of the power meter (PM)
- Values of the photovoltaic inverter (PVI)
- Values of the emergency power supply (EP)

## Installation

The installation of this add-on is pretty straightforward and not different in comparison to installing any other
Home Assistant add-on.

1. Click the Home Assistant My button below to open the add-on on your Home
   Assistant instance.

   [![Open this add-on in your Home Assistant instance.][addon-badge]][addon]

2. If not added already, allow Home Assistant to add the add-on repository to your Home Assistant installation
3. Click the `Install` button to install the add-on.
4. If not done already, activate RSCP on your E3/DC device:
    - `Main menu`
    - `Settings`
    - `Personalize`
    - The password set is required later in the parameters of the software.
5. Configure required configuration. Please find an explanation of all required configuration options below.
6. Start the `rscp2mqtt` add-on.
7. Check the logs of the `rscp2mqtt` add-on to see it in action.

## Configuration

This addon requires a certain minimum configuration before it can be started for the first time. More details regarding
the configuration can be found inside the [rscp2mqtt project][rscp2mqtt-config]

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```yaml
e3dc_ip: 192.0.2.137
e3dc_port: 5033
e3dc_user: photovoltaic@example.com
e3dc_password: example_password_123
e3dc_aes_password: rscp_password_example
mqtt_qos: 0
mqtt_retain: false
logfile: ""
interval: 1
pvi_requests: true
pvi_tracker: 2
pm_requests: true
auto_refresh: true
dryrun: false
```

### Option: `e3dc_ip`

The `e3dc_ip` option is used for the ip address of the E3/DC device. You can look up the IP address at the Settings
dialog at the E3/DC device inside the `Network` section.

### Option: `e3dc_port`

The `e3dc_port` option contains the RSCP port of the E3/DC device, default is 5033

### Option: `e3dc_user`

The `e3dc_user` option has to be filled with the e-mail address used to login at the E3/DC web portal

### Option: `e3dc_password`

The `e3dc_password` option has to be filled with the e-mail address used to login at the E3/DC web portal

### Option: `e3dc_aes_password`

The `e3dc_ip` option is used for the RSCP password which needs to be set directly on the E3/DC device.

### Option: `mqtt_qos`

The `mqtt_qos` defines the Quality of Service setting for all MQTT messages. Possible values are:

- `0`:  At most once
- `1`: At least once
- `2`:  Exactly once

### Option: `mqtt_retain`

The `mqtt_retain` option can be set true or false and defines wether old mqtt messages should be kept retained for newly
connecting clients (`true`) or new clients should just receive messages which were created after the client connected
to the MQTT broker (`false`)

### Option: `logfile`

`logfile` is optional and can be used to define a file system location for the logfile. If empty, logs will be written
to `stdout`

### Option: `interval`

`interval` defines the interval in seconds how often the addon should query the E3/DC device and update mqtt. `ìnterval`
can be set between `1` and `10` seconds, default is `1`.

### Option: `pvi_requests`

`pvi_requests` configures if PV inverter details should be queried from the E3/DC device

### Option: `pvi_tracker`

`pvi_tracker` may be either `1` or `2` and defines if one or both MPP trackers on the E3/DC device are populated with
PV strings.

### Option: `pm_requests`

`pm_requests` configures if power meter details should be queried from the E3/DC device

### Option: `auto_refresh`

The `e3dc_ip` controls if E3/DC power management features can be set by sending MQTT payload to specific topics. See
the [rscp2mqtt project for further details][rscp2mqtt-pm]. Default is `false` so rscp2mqtt works read-only and nobody
is allowed to configure the E3/DC device using MQTT.

### Option: `dryrun`

The `dryrun` option is used for a test mode, so the E3/DC device gets queries, but there is nothing published towards
MQTT. Default is `false`.

## Changelog & Releases

This repository keeps a change log using [GitHub's releases][releases]
functionality.

Releases are based on [Semantic Versioning][semver], and use the format
of `MAJOR.MINOR.PATCH`. In a nutshell, the version will be incremented
based on the following:

- `MAJOR`: Incompatible or major changes.
- `MINOR`: Backwards-compatible new features and enhancements.
- `PATCH`: Backwards-compatible bugfixes and package updates.

## Support

Got questions? If it's related towards the add-on itself, you could [open an issue here][issue] here on GitHub.
If it's related towards rscp2mqtt you better [open an issue][rscp2mqtt-issue] inside its project.

## Authors & contributors

The original setup of this repository is by [Timo Reimann][goebelmeier].

For a full list of all authors and contributors, check [the contributor's page][contributors].

## License

MIT License

Copyright (c) 2023 Timo Reimann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[addon-badge]: https://my.home-assistant.io/badges/supervisor_addon.svg
[addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=rscp2mqtt&repository_url=https%3A%2F%2Fgithub.com%2Fgoebelmeier%2Fha-addons
[contributors]: https://github.com/goebelmeier/ha-addons/graphs/contributors
[goebelmeier]: https://github.com/goebelmeier/
[issue]: https://github.com/goebelmeier/ha-addons/issues
[releases]: https://github.com/goebelmeier/ha-addons/releases
[semver]: http://semver.org/spec/v2.0.0.html
[rscp2mqtt]: https://github.com/pvtom/rscp2mqtt
[rscp2mqtt-config]: https://github.com/pvtom/rscp2mqtt/#configuration--test
[rscp2mqtt-pm]: https://github.com/pvtom/rscp2mqtt/#power-management
[rscp2mqtt-issue]: https://github.com/pvtom/rscp2mqtt/issue
