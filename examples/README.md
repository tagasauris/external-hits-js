## Installing Noejs npm

At Least from Ubuntu 12.04, an old version (0.6.x) of Node is in the standard repository. To install, just run:

```
sudo apt-get install nodejs
```

Obtaining a recent version of Node or installing on older Ubuntu and other apt-based distributions may require a few extra steps. Example install:


```
sudo apt-get update
sudo apt-get install -y python-software-properties python g++ make
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install nodejs
```

## Installing Bower

Bower depends on [Node](http://nodejs.org/) and [npm](http://npmjs.org/).
It's installed globally using npm:

```
npm install -g bower
```

## Example setup

```
cd tagging
bower install
python -m SimpleHTTPServer
```

*Done!* Now open in your browser: http://127.0.0.1:8080/parent.html