# pdc_discovery


A discovery portal for Princeton research data.

Please note: While this is open-source software, we would disourage anyone from trying to just check it out and run it. Princeton specifics, from styling to authentication and authorization, are hard coded, and we have not invested any time in the kind of configurabily that would be needed for use at another institution. Instead it should be taken as an example of breaking a monolithic project into separate components, and developing iteratively in response to local user feedback.

[![CircleCI](https://circleci.com/gh/pulibrary/pdc_discovery.svg?style=svg)](https://circleci.com/gh/pulibrary/pdc_discovery)
[![Coverage Status](https://coveralls.io/repos/github/pulibrary/pdc_discovery/badge.svg?branch=main)](https://coveralls.io/github/pulibrary/pdc_discovery?branch=main)


## Dependencies
* Ruby: 3.1.0
* nodejs: 12.18.3
* yarn: 1.22.10
* postgres: `brew install postgresql@14; brew services start postgresql@14`
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

### Linting Code
We utilize Rubocop for our Ryby code and Prettier for our JavaScript
1. To run rubocop run `bundle exec rubocop`
   1. To allow for autocorrecting of errors run `bundle exec rubocop -a`
1. To run prettier via yar lint run `yarn lint`
   1. To run prettier by itself to see more details on errors run `yarn prettier app/javascript`
   1. To run prettier to autocorrect errors run `yarn prettier --write app/javascript`

### Starting the development server

1. Terminal one: `bin/rails s -p 3000`
3. Access pdc_discovery at [http://localhost:3000/](http://localhost:3000/)

## Deploying

To create a tagged release use the [steps in the RDSS handbook](https://github.com/pulibrary/rdss-handbook/blob/main/release_process.md)

## Indexing research data from PDC Describe

PDC Discovery indexes data from PDC Describe via the following rake task:

```ruby
rake index:research_data
```

This rake task is scheduled to run every 30 minutes on the production and staging servers.

### Solr configuration in production/staging
In production and staging we use Solr cloud to manage our Solr index. Our configuration uses a Solr *alias* to point to the current Solr *collection* that we are using. For example, in staging the alias `pdc-discovery-staging` points to the `pdc-discovery-staging-1` collection.

When we index new content we create a new Solr collection (e.g. `pdc-discovery-staging-2`) and index our data to this new collection. Once the indexing has completed we update our Solr alias to point to this new collection.

Our indexing process automatically toggles between `pdc-discovery-staging-1` and `pdc-discovery-staging-2`.

This dual collection approach allows us to index to a separate area in Solr and prevents users from seeing partial results while we are running the index process.

### Updating the Solr schema in production/staging
To make changes to the Solr schema in production/staging you need to update the files in the [pul_solr](https://github.com/pulibrary/pul_solr) repository and deploy them. The basic steps are:

#### Getting your changes into pul_solr [configuration file for PDC Discovery](https://github.com/pulibrary/pul_solr/tree/main/solr_configs/pdc-discovery)
1. Copy your configuration updates to pul_solr (This command assumes all your projects live in one folder on your machine)
   ```
   cp solr/conf/* ../pul_solr/solr_configs/pdc-discovery/conf/
   ```
1. create a **Draft** PR in pul_solr with your changes (<branch-name> is the name of your new branch for the PR)

#### Getting your changes onto the server
1. Connect to the VPN.
1. Optional. You can tunnel to machine running Solr `ssh -L 8983:localhost:8983 pulsys@lib-solr-staging4` if you want to see your current configuration (e.g. `solrconfig.xml` or `schema.xml`).
1. Make sure you are on the `pul-solr` repo.
1. Deploy the changes, e.g. `BRANCH=<branch-name> bundle exec cap staging deploy`.
1. verify your changes have worked and mark your PR ready for review
1. Once the PR has been merged cordiante a time to deploy the changes to production `bundle exec cap production deploy`

You can see the list of Capistrano environments [here](https://github.com/pulibrary/pul_solr/tree/main/config/deploy)

The deploy will update the configuration for all Solr collections in the given environment, but it does not cause downtime. If you need to manually reload a configuration for a given Solr collection you can do it via the Solr Admin UI.

## Monitoring
You can view the [Honeybadger Uptime check](https://app.honeybadger.io/projects/95072/sites/d932489f-8a8c-4058-964b-df268f589f5a). Currently it checks every minute and will report downtime when two checks fail in a row (i.e. we should know within 2 minutes).

To be notified of downtime enable notifications in Honeybadger under: Settings + Alerts & Integrtions + email (Edit). Enable notifications for "Uptime Events" for "PDC Discovery Production". Notice that email notifications settings are *per project*.

## Mail

### Mail on Development
Mailcatcher is a gem that can also be installed locally.  See the [mailcatcher documentation](https://mailcatcher.me/) for how to run it on your machine.

### Mail on Staging
To See mail that has been sent on the staging server you can utilize capistrano to open up both mailcatcher consoles in your browser.

```
cap staging  mailcatcher:console
```

Look in your default browser for the consoles

### Mail on Production
Emails on production are sent via [Pony Express](https://github.com/pulibrary/pul-it-handbook/blob/f54dfdc7ada1ff993a721f6edb4aa1707bb3a3a5/services/smtp-mail-server.md).


## PPPL / OSTI data feed
There is a data feed at `/pppl_reporting_feed.json`.
It provides a feed of the full JSON blob from PDC Describe for every object tagged as belonging to the Princeton Plasma Physics Laboratory group, sorted by most recently updated first. This is so PPPL can harvest data sets to report to OSTI.
This feed can be paged through using the parameters `per_page` and `page`, like this:

```
https://pdc-discovery-staging.princeton.edu/discovery/pppl_reporting_feed.json?per_page=2&page=3
```

## Export of dataset information
There are two rake tasks that produce CSV files with information about the datasets.

* `bundle exec rake export:summary` generates a file that includes the list of datasets and their size (one line per dataset).
* `bundle exec rake export:details` generates a file that includes the list of datasets and their files (one line per file).

The generated file will be outputed to the `ENV["DATASET_FILE_TALLY_DIR"]` folder and will be named with todays' timestamp.
