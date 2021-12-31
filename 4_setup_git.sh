#!/bin/bash
# This script creates an oTree.git repository and sets up the
# post-receive hook. Whenever code is pushed to the repo, we checkout the code,
# clean the virtual environment, install all requirements in a new virtualenv,
# attempt to migrate the otree database and, if that fails, reset the database.
# finally we restart the webserver.

# set some variables
base_dir=$(pwd)
hooks_dir=$base_dir"/oTree.git/hooks"
otree_dir=$base_dir"/oTree"
venv_dir=$base_dir"/venv_otree"
tmp=$base_dir/.tmp

# create dirs
mkdir oTree oTree.git
cd $base_dir/oTree.git
git init --bare
cd $base_did

# prepare post-hook script
cat <<EOF > $tmp
#!/bin/bash
GIT_WORK_TREE="$otree_dir"
VENV_DIR="$venv_dir"
export GIT_WORK_TREE
git checkout -f

if [[ -d "\$VENV_DIR" ]]; then
    echo "[log] - Cleaning virtualenv"
    rm -rf \$VENV_DIR
    echo "[log] - Finished creating virtualenv"
fi

# recreate venv
echo "[log] - create venv"
python3.9 -m venv \$VENV_DIR

# activate
echo "[log] - activate venv"
echo \$VENV_DIR
source \$VENV_DIR/bin/activate
source /home/\$(whoami)/.otree_env

# install requirements
echo "[log] - install requirements"
pip install -U pip
pip install -r \$GIT_WORK_TREE/requirements.txt

echo "[log] - Staring DB migration"
cd \$GIT_WORK_TREE
if [[ -d "\$GIT_WORK_TREE/otree_core_migrations" ]]
	then
		echo "[log] - detected migrations in otree project dir"
		echo "[log] - attempting migrations"
		otree migrate
		echo "[log] - migrations done"
	else
		echo "[log] - no migrations defined"
		echo "[log] - resetting db"
		otree resetdb --noinput
		echo "[log] - database reset"
fi

cd ..
echo "[log] - Finished DB migration "

echo "[log] - restart services"
sudo /usr/sbin/service supervisor restart
EOF

# move post-receive script into place
mv $tmp $hooks_dir/post-receive
# make executable
chmod +x $hooks_dir/post-receive
