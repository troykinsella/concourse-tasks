
git flow init -fd

if [ -n "$VERSION_PREFIX" ]; then
  egrep -q 'versiontag =\s?$' ~/.git/config && sed -i "s/versiontag =/versiontag = $VERSION_PREFIX/" ~/.git/config
fi
