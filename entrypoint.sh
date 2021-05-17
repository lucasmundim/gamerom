#!/bin/sh
delgroup dialout
addgroup -g "$GROUP_ID" rungroup
adduser -u $UID -D -s /bin/sh -G rungroup runuser
command="cd /app && GEM_HOME="/bundle" PATH=$GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH bundle exec ./exe/gamerom ${@}"
su - runuser -c "$command"
