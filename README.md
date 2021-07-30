# patch-ironic-image

Automated patching ironic images scripts  
* fill the config.txt file with the tag for the container
and most importantly assign a pre-built ironic image to
CONTAINER_TAG
* populate patch-list.txt with one patch per line in
the form "project_dir refsspec"
* run make
