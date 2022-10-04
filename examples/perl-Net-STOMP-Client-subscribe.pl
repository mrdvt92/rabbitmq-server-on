#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw{sleep time};
use Data::Dumper qw{Dumper};
use Net::STOMP::Client;
use JSON::XS qw{decode_json};

my $host       = shift || '127.0.0.1';
my $port       = '61613';
my $login      = 'guest';
my $passcode   = 'guest';
my $vhost      = '/';
my $queue_name = 'example-perl';
my $continue   = 1;
my $rate       = 15;

my $stomp      = Net::STOMP::Client->new(host => $host, port => $port);
$stomp->connect(login => $login, passcode => $passcode, host => $vhost);
my $id         = $stomp->uuid;

# subscribe to the given queue
$stomp->subscribe(
                  'destination'    => "/queue/$queue_name",
                  'id'             => $id,           # required in STOMP 1.1
                  'ack'            => 'client',      # client side acknowledgment
                  'prefetch-count' => 10,
                 );

local $SIG{'INT'} = \&_signal;

# wait for a specified message frame
$stomp->wait_for_frames(callback => \&queue_callback);

sub queue_callback {
  my $timer = time;
  my $self  = shift; #isa Net::STOMP::Client
  my $frame = shift; #ias Net::STOMP::Client::Frame
  #print Dumper($frame);
  my $data  = decode_json($frame->body);
  $self->ack(frame => $frame);
  $timer    = (time - $timer);
  printf "ID: %s, Time: %s, Timer: %0.2f ns\n", $data->{'id'}, $data->{'time'}, $timer * 1e6;
  my $sleep = 1/$rate - $timer; #rate limiter
  sleep $sleep if $sleep > 0;
  return $continue ? 0 : 1;
}

$stomp->unsubscribe(id => $id);
$stomp->disconnect();

sub _signal {
  print "INT\n";
  $continue   = 0;
  print "Continue: $continue\n";
  $SIG{'INT'} = 'DEFAULT';
}
