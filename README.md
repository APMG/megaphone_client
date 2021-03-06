[![Build Status](https://circleci.com/gh/SCPR/megaphone_client.png)](https://circleci.com/gh/SCPR/megaphone_client)

# Megaphone Client
An unofficial Ruby client for the Megaphone API

## Installation
```bash
gem 'megaphone_client', github:"scpr/megaphone_client"
```

## Usage
**Note:** Megaphone API props, such as `externalId`, are in camelCase instead of snake_case because Megaphone's API expects it when accessing their API. So when passing params or putting/posting a hash, use camelCase. When interfacing with the gem's API, use snake_case.

### Configuration
Configure your app to connect to Megaphone, either in an initializer or from your environment files:

```ruby
megaphone = MegaphoneClient.new({
  token: "{megaphone api token}",
  network_id: "{megaphone network id}",
  organization_id: "{megaphone organization id}"
})
```

### Documentation

You can view MegaphoneClient's documentation in RDoc format here:
http://www.rubydoc.info/github/SCPR/megaphone_client/master/

## Tests

#### To run the tests:
```bash
bundle exec rspec spec
```

## Contributing

Pull Requests are encouraged! Suggested practice:
- Fork and make changes
- Submit a PR from fork to this master