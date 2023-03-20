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
3. Click the "Install" button to install the add-on.
4. Configure required configuration. Please find an explanation of all required configuration options below.
5. Start the "rscp2mqtt" add-on.
6. Check the logs of the "rscp2mqtt" add-on to see it in action.

## Configuration

Eventought this add-on is just an example add-on, it does come with some configuration options to play around with.

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```yaml
log_level: info
seconds_between_quotes: 5
```

### Option: `log_level`

The `log_level` option controls the level of log output by the add-on and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually) interesting events.
- `warning`: Exceptional occurrences that are not errors.
- `error`: Runtime errors that do not require immediate action.
- `fatal`: Something went terribly wrong. Add-on becomes unusable.

Please note that each level automatically includes log messages from a
more severe level, e.g., `debug` also shows `info` messages. By default,
the `log_level` is set to `info`, which is the recommended setting unless
you are troubleshooting.

### Option: `seconds_between_quotes`

Sets the number of seconds between the output of each quote. The value
must be between `1` and `120` seconds. This value is set to `5` seconds by
default.

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
[rscp2mqtt-issue]: https://github.com/pvtom/rscp2mqtt/issues