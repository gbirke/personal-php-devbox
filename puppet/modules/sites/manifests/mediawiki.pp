class sites::mediawiki {

  include sites::params

  apache::vhost { 'de.wikimedia.dev':
    docroot  => '/vagrant/www/mediawiki',
    template => '/vagrant/conf/apache/vhost.conf.erb',
  }
  mysql::db { 'mediawiki':
    user => "${sites::params::db_user}",
    password =>  "${sites::params::db_pass}",
    host => 'localhost',
    grant =>  "${sites::params::db_grant}"
  }

  elasticsearch::instance { 'es-01':
    config => {
      'node.name' => 'elasticsearch01',
      'script.disable_dynamic' => false,
      'network.host' => '127.0.0.1',
      'script.groovy.sandbox.class_whitelist' => [
          # Defaults
          'java.util.Date',
          'java.util.Map',
          'java.util.List',
          'java.util.Set',
          'java.util.ArrayList',
          'java.util.Arrays',
          'java.util.HashMap',
          'java.util.HashSet',
          'java.util.UUID',
          'java.math.BigDecimal',
          'org.joda.time.DateTime',
          'org.joda.time.DateTimeZone',
          'org.elasticsearch.common.joda.time.DateTime',
          'org.elasticsearch.common.joda.time.DateTimeZone',
          # Added for Cirrus
          'java.util.Locale',
          'org.apache.lucene.util.automaton.RegExp',
          'org.apache.lucene.util.automaton.CharacterRunAutomaton'
      ],
      'script.groovy.sandbox.package_whitelist' => [
          # Defaults
          'java.util',
          'java.lang',
          'org.joda.time',
          'org.elasticsearch.common.joda.time',
          # Added for Cirrus
          'org.apache.lucene.util.automaton'
      ],
      'script.groovy.sandbox.receiver_whitelist' => [
          # Defaults
          'java.lang.Math',
          'java.lang.Integer',
          '"[I"',
          '"[[I"',
          '"[[[I"',
          'java.lang.Float',
          '"[F"',
          '"[[F"',
          '"[[[F"',
          'java.lang.Double',
          '"[D"',
          '"[[D"',
          '"[[[D"',
          'java.lang.Long',
          '"[J"',
          '"[[J"',
          '"[[[J"',
          'java.lang.Short',
          '"[S"',
          '"[[S"',
          '"[[[S"',
          'java.lang.Character',
          '"[C"',
          '"[[C"',
          '"[[[C"',
          'java.lang.Byte',
          '"[B"',
          '"[[B"',
          '"[[[B"',
          'java.lang.Boolean',
          '"[Z"',
          '"[[Z"',
          '"[[[Z"',
          'java.math.BigDecimal',
          'java.math.BigDecimal',
          'java.util.Arrays',
          'java.util.Date',
          'java.util.List',
          'java.util.Map',
          'java.util.Set',
          'java.lang.Object',
          'org.joda.time.DateTime',
          'org.joda.time.DateTimeUtils',
          'org.joda.time.DateTimeZone',
          'org.joda.time.Instant',
          'org.elasticsearch.common.joda.time.DateTime',
          'org.elasticsearch.common.joda.time.DateTimeUtils',
          'org.elasticsearch.common.joda.time.DateTimeZone',
          'org.elasticsearch.common.joda.time.Instant',
          # Added for Cirrus
          'org.apache.lucene.util.automaton.RegExp',
          'org.apache.lucene.util.automaton.CharacterRunAutomaton'
      ]
    }
  }

}
