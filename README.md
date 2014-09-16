MOMA EAD Export Overrides
==============================

Patches for ArchivesSpace 1.0.9 EAD export issues:

1. Ensure that xml is encoded in utf-8:
https://github.com/archivesspace/archivesspace/issues/68

2. Ensure that `<titleproper>` is populated correctly

#Installation

Download into archivesspace/plugins/moma-exports

Open archivesspace/config/config.xml and uncomment the AppConfig[:plugins] line (if commented)

Add 'moma-exports' to the array

Restart ArchivesSpace



