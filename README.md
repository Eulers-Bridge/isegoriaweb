# README #

**The version of ruby we have been using is ruby 2.1.1p76 (2014-02-24 revision 45161). RAILS 4.1.0**

### Getting started ###

Install:

- [rbenv](https://github.com/rbenv/rbenv)
- [ruby-build](https://github.com/rbenv/ruby-build)
- [rbenv-gem-rehash](https://github.com/rbenv/rbenv-gem-rehash)

Clone from git:

- `git clone https://bitbucket.org/eulersbridge/isegoriaweb.git ~/`

Install `rbenv` and required packages:

- `cd ~/isegoriaweb`
- `rbenv install 2.1.1`
- `rbenv local 2.1.1`
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
