#!/usr/bin/perl
use strict;
use warnings;
use Tie::IxHash qw{};
use Time::HiRes qw{time sleep};
use Net::STOMP::Client;
use JSON::XS qw{encode_json};

local $|        = 1;
my $host        = shift || '127.0.0.1';
my $ws          = My::RabbitMQ::Mgmt->new;
my $stomp       = Net::STOMP::Client->new(host => $host, port => 61613);
$stomp->connect(login => 'guest', passcode => 'guest', host=>'/');
my $queue       = 'example-perl';
my $destination = "/queue/$queue";
my $rate        = 4.25; #messages/second

foreach my $id (1 .. 10000) {
  printf "Consumers: %s, Messages: %s\n", $ws->consumers||0, $ws->messages||0; #undef if new queue

  my $time   = time;
  tie my %payload, 'Tie::IxHash', id=>$id, time=>$time, source=>'perl';
  my $string = encode_json(\%payload);
  printf "Destination: %s, ID: %s, Time: %s, String: %s\n", $destination, $id, $time, $string;
  $stomp->send(destination => $destination, body => "$string\n"); #I like trailing new line
  sleep 1/$rate;
}

$stomp->disconnect();

{
  package My::RabbitMQ::Mgmt;
  use Net::RabbitMQ::Management::API;
  #use Data::Dumper qw{Dumper};
  use base qw{Package::New};
  sub api {
    my $self       = shift;
    $self->{'api'} = Net::RabbitMQ::Management::API->new(url => "http://$host:15672/api") unless $self->{'api'};
    return $self->{'api'}
  }
  sub queue {
    my $self    = shift;
    my $name    = shift;
    if (!$self->{'queue'} or $self->{'queue_timer'} < time - 5) {
      my $request            = $ws->api->get_queue(name => $name, vhost => q{%2f});
      $self->{'queue'}       = $request->content;
      $self->{'queue_timer'} = time;
      #print Dumper($self->{'queue'});
    }
    return $self->{'queue'};
  }
  sub consumers {
    return shift->queue('example-perl')->{'consumers'};
  }
  sub messages {
    return shift->queue('example-perl')->{'messages'};
  }
}

