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
