# Home Assistant rscp2mqtt Add-on: Bridge between an E3/DC pv inverter device and a MQTT broker

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]
[![License][license-shield]](LICENSE.md)

![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports i386 Architecture][i386-shield]

[![Github Actions][github-actions-shield]][github-actions]
![Project Maintenance][maintenance-shield]
[![GitHub Activity][commits-shield]][commits]

[Sponsor Timo via GitHub Sponsors][github-sponsors]

## About

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

[Read the full add-on documentation][docs]

## Support

Got questions? If it's related towards the add-on itself, you could [open an issue here][issue] here on GitHub.
If it's related towards rscp2mqtt you better [open an issue][rscp2mqtt-issue] inside its project.

## Contributing

This is an active open-source project. We are always open to people who want to
use the code or contribute to it.

We have set up a separate document containing our
[contribution guidelines](.github/CONTRIBUTING.md).

Thank you for being involved! :heart_eyes:

## Authors & contributors

The original setup of this repository is by [Timo Reimann][goebelmeier].

For a full list of all authors and contributors, check [the contributor's page][contributors].

## We have got some Home Assistant add-ons for you

Want some more functionality to your Home Assistant instance?

There are multiple add-ons for Home Assistant. For a full list, check out the [GitHub Repository][ha-addon-repository].

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

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[commits-shield]: https://img.shields.io/github/commit-activity/y/goebelmeier/ha-addons.svg
[commits]: https://github.com/goebelmeier/ha-addons/commits/main
[contributors]: https://github.com/goebelmeier/ha-addons/graphs/contributors
[docs]: https://github.com/goebelmeier/ha-addons/blob/main/rscp2mqtt/DOCS.md
[github-actions-shield]: https://github.com/goebelmeier/ha-addons/workflows/CI/badge.svg
[github-actions]: https://github.com/goebelmeier/ha-addons/actions
[github-sponsors]: https://github.com/sponsors/goebelmeier
[goebelmeier]: https://github.com/goebelmeier/
[ha-addon-repository]: https://github.com/hassio-addons/repository
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[issue]: https://github.com/goebelmeier/ha-addons/issues
[license-shield]: https://img.shields.io/github/license/goebelmeier/ha-addons.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2023.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-experimental-orange.svg
[releases-shield]: https://img.shields.io/github/release/goebelmeier/ha-addons.svg
[releases]: https://github.com/goebelmeier/ha-addons/releases
[rscp2mqtt]: https://github.com/pvtom/rscp2mqtt
[rscp2mqtt-issue]: https://github.com/pvtom/rscp2mqtt/issues
