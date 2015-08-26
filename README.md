# Redmine Paranoid Mode plugin

#### Plugin which adds paranoid mode to issues.

## Requirements

Developed and tested on Redmine 3.1.0.

## Installation

1. Go to your Redmine installation's plugins/directory.
2. `git clone https://github.com/efigence/redmine_paranoid_mode`
3. Go back to root directory.
4. `rake redmine:plugins:migrate RAILS_ENV=production`
5. Restart Redmine.

## Usage

Destroyed issues are not actually destroyed but only hidden. These are marked with a new column in issue model: deleted_at date.
Destroyed issues are visible only to admin (filter for deleted_at is available in the issues panel).

Using [paranoia gem](https://github.com/radar/paranoia).

## License

    Redmine Paranoid Mode plugin
    Copyright (C) 2015 efigence S.A.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
