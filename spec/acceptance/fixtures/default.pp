$gerrit_ssh_host_key = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfsIj/jqpI+2CFdjCL6kOiqdORWvxQ2sQbCzSzzmLXic8yVhCCbwarkvEpfUOHG4eyB0vqVZfMffxf0Yy3qjURrsroBCiuJ8GdiAcGdfYwHNfBI0cR6kydBZL537YDasIk0Z3ILzhwf7474LmkVzS7V2tMTb4ZiBS/jUeiHsVp88FZhIBkyhlb/awAGcUxT5U4QBXCAmerYXeB47FPuz9JFOVyF08LzH9JRe9tfXtqaCNhlSdRe/2pPRvn2EIhn5uHWwATACG9MBdrK8xv8LqPOik2w1JkgLWyBj11vDd5I3IjrmREGw8dqImqp0r6MD8rxqADlc1elfDIXYsy+TVH'

$recheck_ssh_public_key = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQCttDjvgwPrJwzo6QSeL1YSizIT3tnDoFV6RKwObA+SwTwsSB/G7RZ5wR7PcgXale0i2tK2n7cUsoegy8f3j1osUE0EkMUFJ0/i3hlj/BsrqS0zAOsoWq9yCiK3iT5wsHNzCmaQLzaA74UvAde0rUojNUD6PStuk5Xvew9MrNifYQ=='

$recheck_ssh_private_key = '-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQCttDjvgwPrJwzo6QSeL1YSizIT3tnDoFV6RKwObA+SwTwsSB/G
7RZ5wR7PcgXale0i2tK2n7cUsoegy8f3j1osUE0EkMUFJ0/i3hlj/BsrqS0zAOso
Wq9yCiK3iT5wsHNzCmaQLzaA74UvAde0rUojNUD6PStuk5Xvew9MrNifYQIDAQAB
AoGAOzFoGY5+/lpPVutZLIKbBTSz+vt9H+H6XvEZ5MxEPlFlLP3i/kn618DMvApy
HjvrFG6XUa55mC8CcvQej6klI9bNe1fd/MQuqwz+okAglhx8YgL8CiJqM36FlyJk
5w4FNb3GBOos8NJgIQpvYpj8VJqa0WV6ErllaBxuSC/8EMUCQQDd1mJHLBhw59El
GHTP1VlSJjmy5gqyvc/uQwDDTlP3wcKqUBiLQLIveAdtrVowQYrxNRDCW/7EgIMB
+VxecBjTAkEAyHQ/fDDM3eQeGz5z3qXsasiWV3nrxqM3hNmKF1XUFQwcWBzDl1Rs
DSawZ4kgxMfJ2tjYUQLnFgabnyBc4SFGewJAYbuWlraVmgB3gvlQVVQwQuH2X5u7
sN2xIs5AIst6cNfbdH9PIOKC3ijqVOafqkzl8rinRomTJ21ayl7a0/xc4wJAOODj
crXWK9AiytA5yJ+EKfio0EGEKWT+x++CQ4TTHPXGxSnERhhqYIDt5TL/3VZjbHnD
R5lvQMy3M7vXHvp2KQJBAMUZ5RcMpW5zASnUfkSUiV9NNFDlzd+Gp1l4JQ2VH4dy
hSGUSarN2V7KnSzac4qGU3uQzMhnYu1QhzljfFc6D0I=
-----END RSA PRIVATE KEY-----
'

include elastic_recheck

$yaml_content = "channels:
  openstack-rainbow-unicorn-pals:
    projects:
      - all
    events:
      - positive
      - negative
messages:
  # | means don't fold newlines, > means do
  found_bug: |
    I noticed Zuul failed, I think you hit bug(s):

    %(bugs)s
  footer: >-
    For more details on this and other bugs, please see
    http://status.openstack.org/elastic-recheck/
  recheck_instructions: >-
    If you believe we've correctly identified the failure, feel free to leave a 'recheck'
    comment to run the tests again.
  unrecognized: >-
    Some of the tests failed in a way that we did not understand. Please help
    us classify these issues so that they can be part of Elastic Recheck
    http://status.openstack.org/elastic-recheck/
  no_bugs_found: >-
    I noticed Zuul failed, refer to:
    https://docs.openstack.org/infra/manual/developers.html#automated-testing
"

# Override channel config file
File <| title == '/etc/elastic-recheck/recheckwatchbot.yaml' |> {
  content => $yaml_content,
  source  => undef,
  require => [
    File['/etc/elastic-recheck'],
  ],
  before  => Class['elastic_recheck::bot'],
}

class { 'elastic_recheck::bot':
  gerrit_host             => 'review.openstack.org',
  gerrit_ssh_host_key     => $gerrit_ssh_host_key,
  recheck_ssh_public_key  => $recheck_ssh_public_key,
  recheck_ssh_private_key => $recheck_ssh_private_key,
  recheck_bot_passwd      => 'recheckbot',
  recheck_bot_nick        => 'recheckbot',
}

# sets up the cron update scripts for static pages
include elastic_recheck::cron
