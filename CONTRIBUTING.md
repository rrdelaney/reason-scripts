# Updating reason-scripts

```sh
# Clone reason-scripts locally
$ git clone git@github.com:reasonml-community/reason-scripts.git

# cd into the new repo
$ cd reason-scripts

# Add the upstream create-react-app repo
$ git remote add upstream git@github.com:facebook/create-react-app.git

# Fetch the remote tag names, we'll need them to determine what version to merge
$ git fetch upstream

# List all the tags we have, we'll find one suitable for merging into reason-scripts
$ git tag --list

# Look for the latest react-scripts tag (ex. react-scripts@1.1.4) and create a branch from it
$ git checkout tags/react-scripts@1.1.4 -b upstream-master

# Create a new branch from upstream only consisting of the react-scripts package
$ git subtree split --prefix=packages/react-scripts -b upstream-react-scripts

# Checkout our new react-scripts branch
$ git checkout upstream-react-scripts

# Make sure everything is correct and it's really only the react-scripts package
$ ls

# Checkout master again so we can start the merge!
$ git checkout master

# Do the merge!!!
$ git merge upstream-react-scripts
```

> Adapted from [Forking a sub directory of a repository on GitHub and making it part of my own repo](https://stackoverflow.com/questions/24577084)
