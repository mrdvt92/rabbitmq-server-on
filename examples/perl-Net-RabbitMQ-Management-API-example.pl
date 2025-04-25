#!/usr/bin/perl
use strict;
use warnings;
use 5.010;
use Time::HiRes qw{sleep};
use Data::Dumper qw{Dumper};
use DateTime;
use Net::RabbitMQ::Management::API;

my $host        = shift || '127.0.0.1';
my $ws          = Net::RabbitMQ::Management::API->new(url => "http://$host:15672/api");
while (1) {
  my $result    = $ws->get_queues;
  my $queues    = $result->content;
  foreach my $queue (@$queues) {
    #print Dumper($queue);
    printf "%s: Vhost: %s, Queue: %s, Messages: %s, Consumers: %s, Publish: %sHz, Ack: %sHz, Growth: %sHz\n",
             DateTime->now,
             $queue->{"vhost"},
             $queue->{"name"},
             $queue->{"messages"},
             $queue->{"consumers"},
             $queue->{'message_stats'}->{'publish_details'}->{'rate'} // 'n/a',
             $queue->{'message_stats'}->{'ack_details'}->{'rate'} // 'n/a',
             $queue->{'messages_details'}->{'rate'} // 'n/a';
  }
  print "-" x 80, "\n" if @$queues > 1;
  sleep 5;
}
