# vagrant-pentaho-biserver-5

## Features

* Ubuntu 16.04.1 LTS
* PostgreSQL 9.5 (without extensions loaded)
* Pentaho BI Server 5.0.1
* Oracle JDK 6

## Configuration

Change **Vagrantfile** as you wish, in the provider settings to configure the number of CPUs and the amount for RAM.
By default, this machine uses 2 cores and 2 GB of RAM (the minimum recommended).

## Usage

* Clone this repo
* Change directory into the cloned folder
* Run *vagrant up*
* Run *vagrant ssh*
* Run */opt/pentaho/start-pentaho.sh*
