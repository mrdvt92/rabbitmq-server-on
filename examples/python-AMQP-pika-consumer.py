#!/usr/bin/env python2
import time
import json
#import pika, an AMQP 0-9-1 client library for Python
import pika

#start a connection object to server on localhost
connection = pika.BlockingConnection()

#setup a channel
channel    = connection.channel()

try:
    #consume from the named queue
    for method_frame, properties, body in channel.consume('example-perl'):
            # Display the message parts and ack the message
            tag  = method_frame.delivery_tag
            data = json.loads(body)
            print "Id: {}, Time: {}, Source: {}".format(data.get("id"), data.get("time"), data.get("source"))
            channel.basic_ack(tag)
            time.sleep(1/15) #rate limit 15 per second
except KeyboardInterrupt:
    print("\nexiting...")

# Cancel the consumer and return any pending messages
requeued_messages = channel.cancel()
print 'Requeued %i messages' % requeued_messages

connection.close()
