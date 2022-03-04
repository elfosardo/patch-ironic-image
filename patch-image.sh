#!/usr/bin/bash

set -euxo pipefail

patch_file="/tmp/${PATCH_LIST}"

while IFS= read -r line
do
    EXEC=$(echo $line | cut -d " " -f1)
    echo $EXEC

    case $EXEC in

        REBUILD)
            # each line is in the form "exec project_dir refsspec" where:
            # - project is the last part of the project url including the org,
            # for example openstack/ironic
            # - refspec is the gerrit refspec of the patch we want to test,
            # for example refs/changes/67/759567/1
            PROJECT=$(echo $line | cut -d " " -f2)
            PROJ_NAME=$(echo $PROJECT | cut -d "/" -f2)
            PROJ_URL="https://opendev.org/$PROJECT"
            REFSPEC=$(echo $line | cut -d " " -f3)

            cd /tmp
            git clone "$PROJ_URL"
            cd "$PROJ_NAME"
            git fetch "$PROJ_URL" "$REFSPEC"
            git checkout FETCH_HEAD

            SKIP_GENERATE_AUTHORS=1 SKIP_WRITE_GIT_CHANGELOG=1 python3 setup.py sdist
            pip3 install --prefix /usr dist/*.tar.gz

            # clean local repo
            cd ..
            rm -fr "$PROJ_NAME"
            ;;

        PATCH)
            PYTHON_LIB_PATH=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib'))")
            PATCH_URL=$(echo $line | cut -d " " -f3)

            cd /tmp
            wget --content-disposition $PATCH_URL
            ZIPPED_PATCH_FILE=$(ls -Art *.zip | tail -n 1)
            unzip $ZIPPED_PATCH_FILE
            PATCH_FILE=$(basename $ZIPPED_PATCH_FILE .zip)
            patch -d$PYTHON_LIB_PATH -f -N -p1 < $PATCH_FILE || true

            # clean patch file
            rm -f "$PATCH_FILE"
            ;;

        *)
            echo "$EXEC operation not supported, closing."
            exit 1
            ;;

    esac

done < "$patch_file"

cd /
