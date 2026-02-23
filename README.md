# Installation

## Compatibility
Redmine 6.0.x - 6.1.x

### If installation dir "/var/lib/redmine" with Passenger:

```sh
$ cd /var/lib/redmine/plugins
$ git clone https://github.com/zsoltrego/redmine_closed_notes_guard.git
$ cd ..
$ bundle config set --local without 'development test'
$ bundle install
$ bundle exec rake redmine:plugins RAILS_ENV=production
$ touch tmp/restart.txt
```

### Test

1. Log in with a normal user.
2. Find a test ticket where a user with the Reporter role is also involved.
3. Close the ticket.
4. Check your user account to see if you can write notes.
5. It also adds a settings interface where you can configure it.
