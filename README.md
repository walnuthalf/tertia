## What is it?
Absinthe-based GraphQL communication server with geolocation capabilities. 

## Example client
Example client implemented with React Apollo can be found 
[here](https://github.com/walnuthalf/dendron).


## The API
Authentication is done with the login mutation. Currently it requires email and password.

Phone number authentication via a random code will be added in the future. 

For HTTPS, "authorization" header must contain "Bearer token" 
where token is what's returned by the login mutation (inside the session object). 

HTTPS URI:
https://made-in-basement.com/api

For websockets, the token must be in the connection parameters. 
You also must specify version 1.0.0 of the protocol (vns=1.0.0), 
else Phoenix won't understand connection/authentication parameters. 

Websocket URI:
 
wss://made-in-basement.com/socket/websocket?vsn=1.0.0

### Mutations:
* login. Described above.
* sendTextMessage. Currently requires a channelId, but if can be made optional, and send to a default channel.
* updateLocation takes a location object with latitude and longitude, 
and sets it as current user's location. 
It can be queried using PostGIS, users can be ordered by proximity to a point,
or filtered by distance. 

### Queries
* channels. Will give all the information to display a list of channels 
such as channel's name, last message (if any).
* channelPage. Returns a paginated list of messages, requires a channelID.
It uses cursor based pagination, 
messages created before the time that the cursor argument specifies will be returned.
Currently the page size is 25 messages.

### Subscriptions
The server will send channel and message objects after certain user activities.

To subscribe for new messages, channelId is required. 

No arguments are needed for the channel subscription.


## Tests
To run tests: 
```bash
  mix test
```
Tertia.RecordCreator module provides an easy way of creating database entries. 

```elixir
Teria.RecordCreator.create(%{user: context.user}, [
  %{
    record_type: :user,
    as: :user2,
    values: %{username: "user2", email: "user2@email.com"}
  },
  :channel,
  %{record_type: :user_channel_assoc, assocs: [:user, :channel]},
  %{
    record_type: :user_channel_assoc,
    as: :user_channel_assoc2,
    assocs: [%{acc_key: :user2, field_name: :user}, :channel]
  },
  %{
    record_type: :message,
    as: :message1,
    assocs: [:user, :channel]
  },
  %{
    record_type: :message,
    as: :message2,
    assocs: [%{acc_key: :user2, field_name: :user}, :channel]
  }
])
```
You can see that create takes a map with DB structs, and a list of specs.
A spec is either an atom, or a map which specifies which module to use (record_type), 
what key to use to put it in the result map (as). 
You can overwrite default values (which are speficied in the Tertia.SampleValues module)
by providing a map in the :values key.


The assocs key must be a list where an element is either an atom, in which case, 
it will look for an entry with that name in the accumulator. 
The key can be specified with :acc_key, 
and :field_name specifies what field should be used for that association, 
_id is appended automatically. 
E.g. %{acc_key: :user2, field_name: :user} means get the value 
usder :user_2 key in the accumulator, and use its id as :user_id field.

It is a bit complicated, but allows for simpler test code.

TertiaWeb.ConnCase provides helper functions for testing resolvers. 
Resolver tests are end to end, since there's no need for views in Absinthe.

However, models, query and command modules 
should have their own tests for separation of responsibility.

## Embedding into an app or site
As long as the client supports both HTTP and websockets, 
and can encode and decode JSON, it can utilize this service.

## Dependencies to install
1) Erlang/OTP
2) Elixir
3) PostgreSQL
4) PostGIS

## Installing on Ubuntu Server
```bash
# Install the Erlang/OTP platform and all of its applications 
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb
apt-get update
apt-get install esl-erlang
# Install Elixir 
apt-get install elixir

# Install PostgreSQL and PostGIS
apt install postgresql-10
apt install postgresql-10-postgis-2.4 
apt install postgresql-10-postgis-scripts
# to get the commandline tools shp2pgsql, raster2pgsql you need to do this
apt install postgis
```

## Installation via Docker
Dockerfile and deployment instructions for Kubernetes are coming soon. 
