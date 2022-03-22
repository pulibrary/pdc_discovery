# pdc_discovery

A discovery portal for Princeton research data. Initially it will provide a better browsing experience for the research data contained in [DataSpace](https://dataspace.princeton.edu).

[![CircleCI](https://circleci.com/gh/pulibrary/pdc_discovery.svg?style=svg)](https://circleci.com/gh/pulibrary/pdc_discovery)
[![Coverage Status](https://coveralls.io/repos/github/pulibrary/pdc_discovery/badge.svg?branch=main)](https://coveralls.io/github/pulibrary/pdc_discovery?branch=main)


## Dependencies
* Ruby: 2.7.5
* nodejs: 12.18.3
* yarn: 1.22.10
* [Lando](https://github.com/lando/lando/releases): 3.0.0

## Updating the banner

Update the file `config/banner.yml`. Note that each environment can have its own banner text.

## Local development

### Setup
1. Check out code
2. `bundle install`
3. `yarn install`

### Starting / stopping services
We use lando to run services required for both test and development environments.

Start and initialize solr and database services with:

`bundle exec rake servers:start`

To stop solr and database services:

`bundle exec rake servers:stop` or `lando stop`

### Running tests
1. Fast: `bundle exec rspec spec`
2. Run in browser: `RUN_IN_BROWSER=true bundle exec rspec spec`

### Starting the development server
*`foreman` is used to enable [Hot Module Replacement for Webpack](https://webpack.js.org/concepts/hot-module-replacement/).*

1. `bundle exec foreman start`
2. Access pdc_discovery at [http://localhost:3000/](http://localhost:3000/)

You can also use two terminal windows instead of `foreman` to start the Rails application and the Webpack server.
This is convenient when you need to step through the code as `byebug` does not always show the prompt when using `foreman`.

1. Terminal one: `bin/rails s -p 3000`
2. Terminal two: `bin/webpack-dev-server`
3. Access pdc_discovery at [http://localhost:3000/](http://localhost:3000/)

## Deploying
pulbot: `pulbot deploy pdc_discovery to [staging|production]`

To create a tagged release use the [steps in the RDSS handbook](https://github.com/pulibrary/rdss-handbook/blob/main/release_process.md)

## Indexing research data from DataSpace

```ruby
rake index:research_data
```

### Updating Solr in production/staging
To make changes to the Solr in production/staging you need to update the files in the [pul_solr](https://github.com/pulibrary/pul_solr) repository and deploy them. The basic steps are:

1. Connect to the VPN.
2. Optional. You can tunnel to machine running Solr `ssh -L 8983:localhost:8983 pulsys@lib-solr-staging4` if you want to see your current configuration (e.g. `solrconfig.xml` or `schema.xml`).
3. Update the [configuration file for PDC Discovery](https://github.com/pulibrary/pul_solr/tree/main/solr_configs/pdc-discovery)
4. Make sure you are on the `pul-solr` repo.
5. Deploy the changes, e.g. `bundle exec cap solr8-staging deploy`.

You can see the list of Capistrano environments [here](https://github.com/pulibrary/pul_solr/tree/main/config/deploy)

The deploy will update the configuration for all Solr collections in the given environment, but it does not cause downtime. If you need to manually reload a configuration for a given Solr collection you can do it via the Solr Admin UI.

## Monitoring
You can view the [Honeybadger Uptime check](https://app.honeybadger.io/projects/95072/sites/d932489f-8a8c-4058-964b-df268f589f5a). Currently it checks every minute and will report downtime when two checks fail in a row (i.e. we should know within 2 minutes).

To be notified of downtime enable notifications in Honeybadger under: Settings + Alerts & Integrtions + email (Edit). Enable notifications for "Uptime Events" for "PDC Discovery Production". Notice that email notifications settings are *per project*.
