## 1.7.0 (29/10/2021)

 * Added custom action `shell`: a bash login shell between component init and cleanup

## 1.6.1 (24/05/2021)

FEATURES:

 * Added `-d/--detailed-exitcode` to propagate terraform exit codes to shell
 * Added `-n/--no-color` appends -co-color to all tf calls
 * Added `-w/--compact-warnings` appends -compact-warnings to all terraform calls

BUG FIXES:

 * Getopt fixes
 * Various small fixes

NOTES:

 * Support for early versions of terraform has been dropped (<0.11)
 * Default backend bucket name has changed, pass in -b to overwrite
 * Scaffold bootstrap updated

## 1.4.3 (16/12/2019)

 * Remove extraneous eval from secret parsing
 * Remove deprecated/irrelevant module-depth parameter

## 1.4.2 (05/02/2018)

 * Add an init with -backend=false in bootstrap mode, otherwise providers are not downloaded
 * Fix bootstrap output that was using a now deprecated bucket resource attribute
 * Add an indicative .terraform-version file for tfenv support in bootstrap

## 1.4.1 (18/12/2017)

 * Remove `-upgrade` from init. Added prematurely. Can go back in when 0.9 support is dropped.

## 1.4.0 (18/12/2017)

 * Support terraform 0.10/0.11, bypassing new built-in approval mechanism.
 * Explicitly cache plugin downloads.
 * Set TF_IN_AUTOMATION.

## 1.3.1 (27/07/2017)

 * Change from error to warn on non-presence of requested group variables file

## 1.3.0 (26/07/2017)

 * Introduce the group variables file functionality

## 1.2.0 (09/06/2017)

 * Merge bootstrap functionality into the main script

## 1.1.4 (16/05/2017)

 * Global and Region scoped variables files

## 1.1.3 (12/04/2017)

 * Support the use of .terraform-version file in components when in the presence of [tfenv](https://github.com/kamatama41/tfenv)

## 1.1.2 (06/04/2017)

 * Provide a case for import that requires the variable file parameters

## 1.1.1 (06/04/2017)

 * Fix 0.9.2+ support for bootstrap.sh

## 1.1.0 (28/03/2017)

 * Move from terraform-0.8 to terraform-0.9
   * Change remote state from manual config to temporary-file "backend"
   * Complain in the code comments about Hashicorp forcing my hand on this
   * Don't push state any more; there's no persisted local copy to push
 * Same change for bootstrap.sh (UNTESTED!)

## 1.0.1 (15/03/2017)

 * Bugfix: Duplicate variable warning conditional to presence of duplicates

## 1.0.0 (14/03/2017)

 * Add CHANGELOG.md
 * Add version and help parameters to bin/terraform.sh
 * Add optional unencrypted S3 parameters
 * Move secrets S3 key path to more appropriate place
 * Test and Warn on duplicate variables
 * Support arbitrary terraform actions
 * Additional comments
