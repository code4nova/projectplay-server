## Setup

### Install dependencies
`bundle install`

### Configure database
`bundle exec rake db:migrate`

### Load data
`bundle exec rake db:seed`

### Refresh data per new measurements/values of 9/19/2012
`bundle exec rake db:datarefresh`

### Start server
`rails server`

## Alternately

### Start vagrant server
`vagrant up`

`vagrant reload`

*This will take a while the first time you run it, but will be faster afterwards.*

