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

You can run this project using either **Lando** (existing/default) or **Devbox** (Nix-based, reproducible local environment).
Both approaches are supported.

### Setup (Devbox)

1. Install Devbox (see `./bin/first-time-setup.sh`).

2. Start a devbox shell:

   ```sh
   devbox shell
   ```

3. Install Ruby gems and JS dependencies:

  ```sh
   devbox run setup
   ```

4. Start Solr and Postgres (Devbox-managed):

  ```sh
    devbox run solr-start
    devbox run solr-create-core
    devbox run postgres-start
  ```

5. Create and migrate the database:

  ```sh
    devbox run db-create
    devbox run db-migrate
  ```

6. Start the Rails server:

  ```sh
    bin/rails s -p 3000
  ```

7. Access PDC Discovery at [http://localhost:3000/](http://localhost:3000)

#### Stopping services (Devbox)

```sh
devbox run solr-stop
devbox run postgres-stop
```

#### Logs / status (Devbox)

```sh
devbox run solr-status
devbox run solr-log
devbox run postgres-status
devbox run postgres-log
```

> Notes:
* Devbox config sets APP_DB_* env vars so Rails uses the devbox-local Postgres socket without changing the existing Lando defaults in config/database.yml.
* On macOS, the Devbox scripts avoid JVM flags that are unsupported by the bundled JDK.

### Setup (Manual)

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
2. To run prettier via yar lint run `yarn lint`
   1. To run prettier by itself to see more details on errors run `yarn prettier app/javascript`
   2. To run prettier to autocorrect errors run `yarn prettier --write app/javascript`

### Starting the development server

1. Terminal one: `bin/rails s -p 3000`
2. Access pdc_discovery at [http://localhost:3000/](http://localhost:3000/)

## Deploying

To create a tagged release use the [steps in the RDSS handbook](https://github.com/pulibrary/rdss-handbook/blob/main/release_process.md)

## Indexing research data from PDC Describe

PDC Discovery indexes data from PDC Describe via the following rake task:

```ruby
rake index:research_data
```

This rake task is scheduled to run every 60 minutes on the production and staging servers.

### Solr configuration in production/staging

In production and staging we use Solr cloud to manage our Solr index. Our configuration uses a Solr *alias* to point to the current Solr *collection* that we are using. For example, in staging the alias `pdc-discovery-staging` points to the `pdc-discovery-staging-new` collection. Our code points to the alias.

At the end of the indexing process we delete any Solr documents that were not touched during the indexing. The delete operation is to make sure we don't keep in PDC Discovery records that are not longer in the source (PDC Describe).

NOTE: We used to use two Solr collections (e.g. `pdc-discovery-staging-1` and `pdc-discovery-staging-2`) and toggle between them. **We do not use this approach anymore**.

#### Creating a new collection

1. open the admin console in pul_solr
2. create a new collection via the collections tab (do not make it end in -1 or -2)
3. on the correct server run `SOLR_URL=http://<solr_url>:8983/solr/<new collection name> bundle exec rake index:research_data
   1. for example `SOLR_URL=http://lib-solr8d-staging.princeton.edu:8983/solr/pdc-discovery-new bundle exec rake index:research_data`
4. delete the alias for `pdc-discovery-staging` or `pdc-discovery-production` and create a new alias with the same name pointing at the new collection  

### Updating the Solr schema in production/staging

To make changes to the Solr schema in production/staging you need to update the files in the [pul_solr](https://github.com/pulibrary/pul_solr) repository and deploy them. The basic steps are:

#### Getting your changes into pul_solr [configuration file for PDC Discovery](https://github.com/pulibrary/pul_solr/tree/main/solr_configs/pdc-discovery)

1. Copy your configuration updates to pul_solr (This command assumes all your projects live in one folder on your machine)

   ```text
   cp solr/conf/* ../pul_solr/solr_configs/pdc-discovery/conf/
   ```

2. create a **Draft** PR in pul_solr with your changes (<branch-name> is the name of your new branch for the PR)

#### Getting your changes onto the server

1. Connect to the VPN.
2. Optional. You can tunnel to machine running Solr `ssh -L 8983:localhost:8983 pulsys@lib-solr-staging4` if you want to see your current configuration (e.g. `solrconfig.xml` or `schema.xml`).
3. Make sure you are on the `pul-solr` repo.
4. Deploy the changes, e.g. `BRANCH=<branch-name> bundle exec cap staging deploy`.
5. verify your changes have worked and mark your PR ready for review
6. Once the PR has been merged cordiante a time to deploy the changes to production `bundle exec cap production deploy`

You can see the list of Capistrano environments [here](https://github.com/pulibrary/pul_solr/tree/main/config/deploy)

The deploy will update the configuration for all Solr collections in the given environment, but it does not cause downtime. If you need to manually reload a configuration for a given Solr collection you can do it via the Solr Admin UI.

## Monitoring

You can view the [Honeybadger Uptime check](https://app.honeybadger.io/projects/95072/sites/d932489f-8a8c-4058-964b-df268f589f5a). Currently it checks every minute and will report downtime when two checks fail in a row (i.e. we should know within 2 minutes).

To be notified of downtime enable notifications in Honeybadger under: Settings + Alerts & Integrtions + email (Edit). Enable notifications for "Uptime Events" for "PDC Discovery Production". Notice that email notifications settings are *per project*.

## Mail

### Mail on Development

Mailcatcher is a gem that can also be installed locally. See the [mailcatcher documentation](https://mailcatcher.me/) for how to run it on your machine.

### Mail on Staging

To See mail that has been sent on the staging server you can utilize capistrano to open up both mailcatcher consoles in your browser.

```text
cap staging  mailcatcher:console
```

Look in your default browser for the consoles

### Mail on Production

Emails on production are sent via [Pony Express](https://github.com/pulibrary/pul-it-handbook/blob/f54dfdc7ada1ff993a721f6edb4aa1707bb3a3a5/services/smtp-mail-server.md).

## PPPL / OSTI data feed

There is a data feed at `/pppl_reporting_feed.json`.
It provides a feed of the full JSON blob from PDC Describe for every object tagged as belonging to the Princeton Plasma Physics Laboratory group, sorted by most recently updated first. This is so PPPL can harvest data sets to report to OSTI.
This feed can be paged through using the parameters `per_page` and `page`, like this:

```text
https://pdc-discovery-staging.princeton.edu/discovery/pppl_reporting_feed.json?per_page=2&page=3
```

## Export of dataset information

There are two rake tasks that produce CSV files with information about the datasets.

* `bundle exec rake export:summary` generates a file that includes the list of datasets and their size (one line per dataset).
* `bundle exec rake export:details` generates a file that includes the list of datasets and their files (one line per file).

The generated file will be outputed to the `ENV["DATASET_FILE_TALLY_DIR"]` folder and will be named with todays' timestamp.
