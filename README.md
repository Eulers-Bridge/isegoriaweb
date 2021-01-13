# README #

This is a legacy repository and was superseded by the javascript repository. Do not use. 

**Currently on Ruby 2.1.8, Rails 4.1.0**

### Getting started ###

## Docker (Recommended) ##
Install:

- [Docker for Mac/Windows](https://www.docker.com/products/docker)

Clone from git:

- `git clone https://bitbucket.org/eulersbridge/isegoriaweb.git ~/`

Run:

- `cd ~/isegoriaweb`
- `docker-compose up --build`

## Local ##
Install:

- [rbenv](https://github.com/rbenv/rbenv)
- [ruby-build](https://github.com/rbenv/ruby-build)
- [rbenv-gem-rehash](https://github.com/rbenv/rbenv-gem-rehash)

Clone from git:

- `git clone https://bitbucket.org/eulersbridge/isegoriaweb.git ~/`

Install `rbenv` and required packages:

- `cd ~/isegoriaweb`
- `rbenv install 2.1.8`
- `rbenv local 2.1.8`
- `gem install bundler`
- `bundle install`

Add dev server aliases to your `/etc/hosts` file:

```
54.206.36.220 graphdb                                                          
54.79.70.241 buildserver                                                       
54.79.70.241 eulersbridge
```

Run the server:

- `rails server`
