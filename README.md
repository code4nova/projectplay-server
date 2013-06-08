## Setup

### Install dependencies - here without production gem requirements (for a development setup)
`bundle install --without production`

### Configure database
`bundle exec rake db:migrate`

### Load data per new measurements/values of 9/19/2012
`bundle exec rake db:newdataseed`

### Start server
`rails server`

## Alternately

### Start vagrant server
`vagrant up`

`vagrant reload`

*This will take a while the first time you run it, but will be faster afterwards.*

