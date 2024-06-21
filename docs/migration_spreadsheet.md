# Generating the DataSpace Migration Spreadsheet

## Generating a full migration spreadsheet
1. ssh to the production pdc-discovery server `ssh deploy@pdc-discovery-prod1`
1. `cd /opt/pdc_discovery/current`
1. `bundle exec rake migration:produce_full_spreadsheet`
1. The output will be located in tmp `ls -ltr /tmp/full_dataspace_migration_spreadsheet_*`

## Generating a delta 
1. Download the current migration spreadsheet as a .csv file
2. Check whether any new collections should be added to `config/collections.csv` (and add them, and deploy if necessary)
3. Copy the current migration spreadsheet csv file to the PDC Discovery production server: `scp ~/Downloads/current_spreadsheet.csv deploy@pdc-discovery-prod1.princeton.edu:/tmp`
4. ssh to that server: `ssh deploy@pdc-discovery-prod1.princeton.edu`
5. Go to where the software is deployed
6. Invoke the `produce_delta_spreadsheet` rake task and point to the current migration spreadsheet, like this:
   ```
     bundle exec rake migration:produce_delta_spreadsheet\["/tmp/current_spreadsheet.csv"]
   ```
7. It will produce a spreadsheet named like `delta_dataspace_migration_spreadsheet_2023_08_22_19_55.csv` in the `/tmp` directory.
8. Copy that spreadsheet to your local machine, and then import it into a new tab on the migration spreadsheet.
